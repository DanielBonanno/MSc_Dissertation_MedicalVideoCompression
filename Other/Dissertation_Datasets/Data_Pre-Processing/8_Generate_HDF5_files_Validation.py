from PIL import Image
import numpy as np
import h5py

import math

from skimage import data, img_as_float
from skimage.measure import compare_ssim as ssim

from scipy import ndimage


HR_data =[]
LR_data = []
MC_data = []
patch_reshaped = []

counter_patches = 0
fp_HR = open('../Validation/Validation_HR.txt') 
fp_LR = open('../Validation/Validation_LR.txt')  
fp_MC = open('../Validation/Validation_MC.txt')  

all_black_2 = np.double(np.full((32,32), 0))
file_counter = 0

while 1:
	line_HR = fp_HR.readline().strip()
	line_LR = fp_LR.readline().strip()
	line_MC = fp_MC.readline().strip()
	if not line_HR:
		break
	else:
		print counter_patches
		counter_patches += 1
	 	patch = Image.open(line_HR)
		patch_width, patch_height = patch.size
	 	patch_array = np.transpose(np.array(patch))
	 	patch_reshaped = np.reshape(patch_array, (patch_width, patch_height,1))

		current_patch = np.double(np.reshape(patch_reshaped, (patch_width, patch_height)))/255.0;

		if(np.std(current_patch) != 0):
			dx = ndimage.sobel(current_patch, 1)  # horizontal derivative
			dy = ndimage.sobel(current_patch, 0)  # vertical derivative
			mag = np.hypot(dx, dy)  # magnitude

			if(np.max(mag)!= 0):
				mag = mag/np.max(mag)

			q_1 = ssim(all_black_2, mag[0:32,0:32], data_range=1)
			q_2 = ssim(all_black_2, mag[0:32,32:64], data_range=1)
			q_3 = ssim(all_black_2, mag[32:64,0:32], data_range=1)
			q_4 = ssim(all_black_2, mag[32:64,32:64], data_range=1)
			if( ((q_1+q_2+q_3+q_4)/4) < 0.8):
				HR_data.append(patch_reshaped)


				
			 	patch = Image.open(line_LR)
				patch_width, patch_height = patch.size
			 	patch_array = np.transpose(np.array(patch))
			 	patch_reshaped = np.reshape(patch_array, (patch_width, patch_height,1))
				LR_data.append(patch_reshaped)


				
			 	patch = Image.open(line_MC)
				patch_width, patch_height = patch.size
			 	patch_array = np.transpose(np.array(patch))
			 	patch_reshaped = np.reshape(patch_array, (patch_width, patch_height,1))
				MC_data.append(patch_reshaped)
			

	if(len(HR_data)==250000):
		with h5py.File('../Validation_Data_%d.h5' %file_counter, 'w') as fp:
			fp['HR_data'] = HR_data
			fp['LR_data'] = LR_data
			fp['MC_data'] = MC_data
			HR_data = []
			LR_data = []
			MC_data = []
			file_counter += 1
			



with h5py.File('../Validation_Data_%d.h5' %file_counter, 'w') as fp:

	fp['HR_data'] = HR_data
	fp['LR_data'] = LR_data
	fp['MC_data'] = MC_data
		
fp_HR.close()
fp_LR.close()
fp_MC.close()
