import matplotlib.pyplot as plt
import numpy as np
import h5py
import random

from keras.models import Sequential, load_model
from keras.layers import Conv2D, Conv2DTranspose, PReLU, Merge, Reshape, BatchNormalization
from keras.optimizers import SGD, Adam
from keras.losses import mean_absolute_error as MAE
from keras.losses import mean_squared_error as MSE
from keras.initializers import Constant
from keras import regularizers
from keras import backend as K
from keras.utils import plot_model
from keras.callbacks import CSVLogger, ModelCheckpoint, EarlyStopping

import tensorflow as tf

def generate_data(filepath, batch_size):
	file = h5py.File(filepath, 'r')
	HR_dataset = file['HR_data']
	LR_dataset = file['LR_data']
	MC_dataset = file['MC_data']
	number_of_samples = len(HR_dataset)
	number_of_batches = number_of_samples/batch_size
	counter = 0

	while True:
		data_HR_batch = []
		data_LR_batch = []
		data_MC_batch = []
		
		data_HR_batch = HR_dataset[counter*batch_size:(counter+1)*batch_size]/255.0
		data_LR_batch = LR_dataset[counter*batch_size:(counter+1)*batch_size]/255.0
		data_MC_batch = MC_dataset[counter*batch_size:(counter+1)*batch_size]/255.0

		counter = (counter+1)%number_of_batches
		yield ([np.array(data_LR_batch), np.array(data_MC_batch)], [np.array(data_HR_batch)])

#https://github.com/titu1994/Image-Super-Resolution/blob/master/models.py
def PSNR(y_true, y_pred):
 	return -10. * K.log(K.mean(K.square(y_pred - y_true))) / K.log(10.)

def SSIM(y_true, y_pred):
        c1 = (0.01 ** 2)
        c2 = (0.03 ** 2)

	gaussian = make_kernel(1.5, 11)

	mu_true = tf.nn.conv2d(y_true, gaussian, strides=[1, 1, 1, 1], padding='VALID')	
	mu_pred = tf.nn.conv2d(y_pred, gaussian, strides=[1, 1, 1, 1], padding='VALID')

	mu_true_squared = K.square(mu_true)
	mu_pred_squared = K.square(mu_pred)

	y_true_pred = tf.multiply(y_true, y_pred)

	#covariance = Gaussian of img1*img2 - mu1*mu2
	covar = tf.nn.conv2d(y_true_pred, gaussian, strides=[1, 1, 1, 1], padding='VALID') - tf.multiply(mu_true, mu_pred)

	y_true_squared = K.square(y_true)
	y_pred_squared = K.square(y_pred)

	#sigma_squared = Gaussian of img1^2 - mu1^2
	sigma_true_squared = tf.nn.conv2d(y_true_squared, gaussian, strides=[1, 1, 1, 1], padding='VALID') - mu_true_squared
	sigma_pred_squared = tf.nn.conv2d(y_pred_squared, gaussian, strides=[1, 1, 1, 1], padding='VALID') - mu_pred_squared

	#numerator = 2* covar + c2
	mult = tf.multiply(mu_true, mu_pred)
	num_1 = tf.nn.bias_add(tf.scalar_mul(2, mult), [c1])
	
	num_2 =tf.nn.bias_add(tf.scalar_mul(2, covar), [c2])
	num = tf.multiply(num_1, num_2)

	add = tf.add(mu_true_squared, mu_pred_squared)
	den_1 =tf.nn.bias_add(add, [c1])		#denominator = mu_true^2+mu_pred^2 + c1

	add = tf.add(sigma_true_squared, sigma_pred_squared)
	den_2 =tf.nn.bias_add(add, [c2])		#denominator = sigma_true^2+sigma_pred^2 + c2

	den = tf.multiply(den_1, den_2)
	#return (1.0-K.mean(tf.div(num,den)))/2.0
	return (K.mean(tf.div(num,den)))

def gaussian(x, mu, sigma):
    return np.exp(-(float(x) - float(mu)) ** 2 / (2 * sigma ** 2))

def make_kernel(sigma, size):
    # kernel = size, but minimum 3x3 matrix
    kernel_size = max(3, size)
    mean = np.floor(0.5 * kernel_size)
    kernel_1d = np.array([gaussian(x, mean, sigma) for x in range(kernel_size)])
    # make 2D kernel
    np_kernel = np.outer(kernel_1d, kernel_1d).astype(dtype=K.floatx())
    # normalize kernel by sum of elements
    kernel = np_kernel / np.sum(np_kernel)
    kernel = np.reshape(kernel, (kernel_size, kernel_size, 1,1))	#height, width, in_channels, out_channel
    return kernel



def SSIM_l(y_true, y_pred):
	gaussian = make_kernel(1.5, 3)
	c1 = 0.01 ** 2

	mu_true = tf.nn.conv2d(y_true, gaussian, strides=[1, 1, 1, 1], padding='VALID')	
	mu_pred = tf.nn.conv2d(y_pred, gaussian, strides=[1, 1, 1, 1], padding='VALID')

	mu_true_squared = K.square(mu_true)
	mu_pred_squared = K.square(mu_pred)

	mult = tf.multiply(mu_true, mu_pred)
	num = tf.nn.bias_add(tf.scalar_mul(2, mult), [c1])	#numerator = 2*mu_true*mu_pred + c1

	add = tf.add(mu_true_squared, mu_pred_squared)
	den =tf.nn.bias_add(add, [c1])		#denominator = mu_true^2+mu_pred^2 + c1

 	return K.mean(tf.div(num,den))

def SSIM_cs(y_true, y_pred, iteration):
	sizes = [11,9,7,5,3]
	gaussian = make_kernel(1.5, sizes[iteration])
        c2 = 0.03 ** 2

	y_true_pred = tf.multiply(y_true, y_pred)

	mu_true = tf.nn.conv2d(y_true, gaussian, strides=[1, 1, 1, 1], padding='VALID')	
	mu_pred = tf.nn.conv2d(y_pred, gaussian, strides=[1, 1, 1, 1], padding='VALID')



	#covariance = Gaussian of img1*img2 - mu1*mu2
	covar = tf.nn.conv2d(y_true_pred, gaussian, strides=[1, 1, 1, 1], padding='VALID') - tf.multiply(mu_true, mu_pred)


	#numerator = 2* covar + c2
	num = tf.nn.bias_add(tf.scalar_mul(2, covar), [c2])
	
	y_true_squared = K.square(y_true)
	y_pred_squared = K.square(y_pred)


	mu_true_squared = K.square(mu_true)
	mu_pred_squared = K.square(mu_pred)

	#sigma_squared = Gaussian of img1^2 - mu1^2
	sigma_true_squared = tf.nn.conv2d(y_true_squared, gaussian, strides=[1, 1, 1, 1], padding='VALID') - mu_true_squared
	sigma_pred_squared = tf.nn.conv2d(y_pred_squared, gaussian, strides=[1, 1, 1, 1], padding='VALID') - mu_pred_squared

	add = tf.add(sigma_true_squared, sigma_pred_squared)
	den =tf.nn.bias_add(add, [c2])		#denominator = sigma_true^2+sigma_pred^2 + c2


 	return K.mean(tf.div(num,den))

def MSSSIM_Loss(y_true, y_pred):
	iterations = 5
	weight = [0.0448, 0.2856, 0.3001, 0.2363, 0.1333]
	shape = [[32,32], [16,16], [8,8], [4,4]]
	kernel_size = [7,5,3,3]

	ms_ssim = []
	
	img1 = y_true
	img2 = y_pred



	for iteration in range(iterations):

		#Obatain c*s for current iteration

		ms_ssim.append(SSIM_cs(img1, img2, iteration)**weight[iteration])

		#Blur and Shrink
		#cs for all 5 iterations -> shrink 4 times (the last is required for calculation of l)
		if(iteration!=(iterations-1)):
			gaussian = make_kernel(1,kernel_size[iteration])
			img1 = tf.nn.conv2d(img1, gaussian, strides=[1, 1, 1, 1], padding='SAME')	
			img2 = tf.nn.conv2d(img2, gaussian, strides=[1, 1, 1, 1], padding='SAME')

			img1 = tf.image.resize_images(img1,  shape[iteration])
			img2 = tf.image.resize_images(img2,  shape[iteration])


	ms_ssim = tf.stack(ms_ssim)

	cs_val = tf.reduce_prod(ms_ssim)

	l_val = SSIM_l(img1, img2)**weight[4]
	return (1.0-tf.multiply(cs_val, l_val))/2.0


def Mix_Loss(y_true, y_pred):
	msssim_loss = MSSSIM_Loss(y_true, y_pred)
	L1_loss = K.mean(K.abs(y_pred - y_true), axis=-1)

	return (0.6*msssim_loss+0.4*L1_loss)


def Create_Model(num_layers, upscale_factor, input_shape, batch_norm, to_train):
	model_initial_LR = Sequential()
	model_initial_MC = Sequential()
	model = Sequential()

	#LR
	#feature extraction
	model_initial_LR.add(Conv2D(filters=56, kernel_size=5, strides=(1,1), padding='same', data_format='channels_last', dilation_rate=(1,1), activation=None, use_bias=True, kernel_initializer='he_normal', bias_initializer="zeros",  kernel_regularizer=regularizers.l2(regularization), bias_regularizer=regularizers.l2(regularization), input_shape = input_shape, trainable = to_train))
	

	model_initial_LR.add(PReLU(alpha_initializer='zeros', alpha_regularizer=None, alpha_constraint=None, shared_axes=[1,2], trainable = to_train))

	#shrinking
	model_initial_LR.add(Conv2D(filters=12, kernel_size=1, strides=(1,1), padding='same', data_format='channels_last', dilation_rate=(1,1), activation=None, use_bias=True, kernel_initializer='he_normal', bias_initializer="zeros",  kernel_regularizer=regularizers.l2(regularization), bias_regularizer=regularizers.l2(regularization), trainable = to_train))

	model_initial_LR.add(PReLU(alpha_initializer='zeros', alpha_regularizer=None, alpha_constraint=None, shared_axes=[1,2], trainable = to_train))

	#Conv_1
	model_initial_LR.add(Conv2D(filters=12, kernel_size=3, strides=(1,1), padding='same', data_format='channels_last', dilation_rate=(1,1), activation=None, use_bias=True, kernel_initializer='he_normal', bias_initializer="zeros",  kernel_regularizer=regularizers.l2(regularization), bias_regularizer=regularizers.l2(regularization), trainable = to_train))

	model_initial_LR.add(PReLU(alpha_initializer='zeros', alpha_regularizer=None, alpha_constraint=None, shared_axes=[1,2],trainable = to_train))

	#MC
	#feature extraction
	model_initial_MC.add(Conv2D(filters=56, kernel_size=5, strides=(1,1), padding='same', data_format='channels_last', dilation_rate=(1,1), activation=None, use_bias=True, kernel_initializer='he_normal', bias_initializer="zeros",  kernel_regularizer=regularizers.l2(regularization), bias_regularizer=regularizers.l2(regularization), input_shape = input_shape, trainable = to_train))

	model_initial_MC.add(PReLU(alpha_initializer='zeros', alpha_regularizer=None, alpha_constraint=None, shared_axes=[1,2], trainable = to_train))

	#shrinking
	model_initial_MC.add(Conv2D(filters=12, kernel_size=1, strides=(1,1), padding='same', data_format='channels_last', dilation_rate=(1,1), activation=None, use_bias=True, kernel_initializer='he_normal', bias_initializer="zeros",  kernel_regularizer=regularizers.l2(regularization), bias_regularizer=regularizers.l2(regularization), trainable = to_train))


	model_initial_MC.add(PReLU(alpha_initializer='zeros', alpha_regularizer=None, alpha_constraint=None, shared_axes=[1,2], trainable = to_train))

	#Conv_1
	model_initial_MC.add(Conv2D(filters=12, kernel_size=3, strides=(1,1), padding='same', data_format='channels_last', dilation_rate=(1,1), activation=None, use_bias=True, kernel_initializer='he_normal', bias_initializer="zeros",  kernel_regularizer=regularizers.l2(regularization), bias_regularizer=regularizers.l2(regularization), trainable = to_train))

	model_initial_MC.add(PReLU(alpha_initializer='zeros', alpha_regularizer=None, alpha_constraint=None, shared_axes=[1,2], trainable = to_train))

	#-----------------------------------------------------------------------------
	#Merged model

	merged = Merge([model_initial_LR, model_initial_MC], mode='concat', concat_axis=3)

	model.add(merged)

	#adding other layers
	for i in range(0,num_layers):

		model.add(Conv2D(filters=12, kernel_size=3, strides=(1,1), padding='same', data_format='channels_last', dilation_rate=(1,1), activation=None, use_bias=True, kernel_initializer='he_normal', bias_initializer="zeros",  kernel_regularizer=regularizers.l2(regularization), bias_regularizer=regularizers.l2(regularization), trainable = to_train))

		model.add(PReLU(alpha_initializer='zeros', alpha_regularizer=None, alpha_constraint=None, shared_axes=[1,2], trainable = to_train))

	#expanding
	model.add(Conv2D(filters=56, kernel_size=1, strides=(1,1), padding='same', data_format='channels_last', dilation_rate=(1,1), activation=None, use_bias=True, kernel_initializer='he_normal', bias_initializer="zeros",  kernel_regularizer=regularizers.l2(regularization), bias_regularizer=regularizers.l2(regularization), trainable = to_train))

	model.add(PReLU(alpha_initializer='zeros', alpha_regularizer=None, alpha_constraint=None, shared_axes=[1,2], trainable = to_train))

	model.add(Conv2DTranspose(filters=1, kernel_size=10, strides=(upscale_factor,upscale_factor), padding='same', data_format='channels_last', activation=None, use_bias=True, kernel_initializer='he_normal', bias_initializer="zeros",  kernel_regularizer=regularizers.l2(regularization), bias_regularizer=regularizers.l2(regularization)))	

	return model


num_layers = 6
input_shape = (None,None,1)
upscale_factor = 2
log_file_path = './log.csv'
weights_file_path = './weights_M6_.{epoch:06d}.h5'
final_weights_path = './Weights/MVSRCNN_M6_x2.h5'
plot = True
training_file_path = '../Training/Training_Data.h5'
validation_file_path = '../Validation/Validation_Data.h5'
batch_norm = False
to_train = True
regularization = 0.00001
Number_of_Epochs = 300

model = Create_Model(num_layers, upscale_factor, input_shape, batch_norm, to_train)
model.add(Reshape((64,64,1)))
#plot model
if(plot):
	plot_model(model, to_file='model.png', show_shapes=True)

#compile model
model.compile(optimizer=Adam(lr=0.0001, beta_1=0.9, beta_2=0.999, epsilon=1e-8),loss=Mix_Loss, metrics = ['mse', 'mae', SSIM, MSSSIM_Loss])


#Callbacks for logging and saving after every epoch and early stopping
log_callback = CSVLogger(log_file_path, separator=',', append=False)
checkpoint_callback = ModelCheckpoint(weights_file_path, verbose=0, save_weights_only=True, mode='auto', period=1)
early_stopping_callback = EarlyStopping(monitor='val_loss', min_delta=0.0001, patience=1000, verbose=0, mode='min')

#Training
model.fit_generator(generator=generate_data(training_file_path,128), steps_per_epoch = 11052, epochs = Number_of_Epochs, verbose = 1, callbacks=[log_callback, checkpoint_callback, early_stopping_callback], validation_data = generate_data(validation_file_path,128), validation_steps = 3684)

model.save_weights(final_weights_path)

