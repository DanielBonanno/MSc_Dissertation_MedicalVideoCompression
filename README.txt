This Repo contains 2 Main folders: one containing the documentation and the 
other containing the code developed.

This ReadMe file will try to explain the use of each of the scripts presented.

A sample CT scan is provided in Training/CT.
Note that similar files can be used in Validation/CT and Testing/CT
Furthermore, note that all scripts have been designed such that 
Training, Testing and Validation folders can have CT, MRI and Ultrasound
folders inside them. Whilst CT and MRI are expected to contain dicom files,
it is expected that Ultrasound has ultrasound videos.

-----------------------------------------------------------------------
REQUIREMENTS
-----------------------------------------------------------------------

ffmpeg
DCMTK (if extracting images from DICOM format)
OpenCV 3.4.0
Keras 2.14 with Tensorflow 1.5.0
Python Libraries: Pillow, numpy ,h5py

-----------------------------------------------------------------------
Dissertation_Code Folder
-----------------------------------------------------------------------

This directory contains scripts created with C++. These make use of OpenCV.
The aim of these scripts is to manipulate the frames or extract information
from them. These are usually used in bash scipts found in other directories.

- Add_Enhancement_Layer
	Inputs: 	Path to Image
			Path to Enhancement Layer Image
			Co-Ordinate File Path in the form:
				top left x co-ordinate
				top left y co-ordinate
				width
				height
			Output Image Path

	Outputs:	Image with the Enhancement Layer added to the co-ordinates
			specified by the Co-Oridnate File

	Use: 		Adds the Enhancement Layer to the Image specified in the
			arguments. The location of where the Enhancement Layer
			is added is specified by the Co-Ordinate File Path.


- Get_Enhancement_Layer
	Inputs: 	Path to Original Image
			Path to Distroted Image
			Co-Ordinate File Path in the form:
				top left x co-ordinate
				top left y co-ordinate
				width
				height
			Output Enhancement Layer Path

	Outputs:	Enhancement Layer image for the co-ordinates specified by
			the co-ordinate file path

	Use: 		Extracts the Enhancement Layer (as specified by the 
			documentation) between the Original Image and the 
			Distorted Image at the co-ordinates specified by the 
			co-ordinate file.


- Get_Overlay

	Inputs: 	Path to Frame
			Co-Ordinate File Path in the form:
				top left x co-ordinate
				top left y co-ordinate
				width
				height
			Output Overlay Path

	Outputs:	Transaparent Overlay image

	Use: 		Obtains an overlay image which shows a red box surrounding
			the ROI detailed by the co-ordinates file. The other
			areas are transparent. This is used during subjective
			testing to show where the ROI is located.

- Image_Metrics
	Inputs: 	Path to Image_1
			Path to Image_2

	Outputs:	/

	Use: 		Displays on screen the MAE, PSNR, SSIM and MS-SSIM
			between Image_1 and Image_2, in that order.


- Image_Patches
	Inputs: 	Path to Input Image
			Patch Size (16, 32, 64)
			Path to Output Folder

	Outputs:	Patches to Output Folder

	Use: 		Used to Patch-ify an image. This is used to obtain
			Training/Validation data from images.
			(Note: This data is not used in this format for training
			/validation purposes. It is converted to HDF5).


- Image_Subsample
	Inputs: 	Path to Image
			Path to Output Image
			Scaling Factor (2 or 4)

	Outputs:	Downscaled Image

	Use: 		Performs image downscaling using OpenCV's Bicubic Interpolation.


- Image_Subsample_Padded

	Inputs: 	Path to Image
			Path to Padded Image
			Path to Scaled Output Image
			Scaling Factor (2 or 4)

	Outputs:	Padded Image, Upscaled Image

	Use: 		Performs image padding, such that the input image is a multiple of 8,
			Performs image downscaling using OpenCV's Bicubic Interpolation.



- Image_Upsample
	Inputs: 	Path to Image
			Path to Output Image
			Scaling Factor (2 or 4)

	Outputs:	Upscaled Image

	Use: 		Performs image upscaling using OpenCV's Bicubic Interpolation.
			Diplays also the time taken to upscale


- Motion_Compensation
	Inputs: 	Path to Frame_1
			Path to Frame_2
			Path to Output Frame
			Preset (1: Medium, 2: Fast, 3: Ultrafast)

	Outputs:	Motion Compensated Frame

	Use: 		Performs motion compensation between Frame_1 and Frame_2
			using OpenCV's Optical Flow Alogrithm. The Preset used
			is specified in the arguemnts.


-----------------------------------------------------------------------
Dissertation_Datasets Folder
-----------------------------------------------------------------------
This folder contains the datasets as well as scripts which make use of the
above and other python code. The CNN models are also found here. The following 
sections will describe each folder and its contents.

NOTE: In the Training, Testing and Validation folders, only sample datasets are present.
The actual datasets are not available in this repo.

-----------------------------------------------------------------------
Dissertation_Datasets/Testing/HEVC
-----------------------------------------------------------------------
Contains the HEVC encoder and decoder, as downloaded from:
https://hevc.hhi.fraunhofer.de/svn/svn_HEVCSoftware/

It also contains 2 config files:

-Medical_Video_Config_File --> Used to perform lossy compression
-Enhancement_Layer_Config_File --> Used to perform lossless compression of the EL and of the video

These are modified as described in the documentation

-----------------------------------------------------------------------
Dissertation_Datasets/Keras_Models
-----------------------------------------------------------------------
Contains everything related to the CNNs
(MVSRCNN = Medical Video Super Resolution Convolutional Neural Network)
Note: Some file paths might need to be adjusted manually


-KERAS_MVSRCNN.py
	Used to train the x2 CNN. 
	Specify in the script:

		num_layers 		= Refers to the M parameter inthe documentation
		log_file_path 		= Where to store the log file generated. This holds the validation loss, MSE, ... per epoch
		weights_file_path 	= Where to store the files containing the weights per epoch
		final_weights_path 	= Where to store the weights file containing the final version of the weights
		plot 			= True/Falase Variable. Specifies whether to get a plot of the model
		training_file_path 	= Path to .h5 file containing the training dataset
		validation_file_path 	= Path to .h5 file containing the validation dataset
		Number_of_Epochs 	= Number of iterations to train

-KERAS_MVSRCNN_x4.py
	Used to train the x4 CNN.
	Specify in the script:
		As in KERAS_MVSCRNN.py

		Aditionally:
		load_weights 		= Specify the path from where to load the final x2 weights, used to initialisation.
		Comment out: 		model.load_weights(load_weights) if you do not want to initialise with x2 weights.




-KERAS_Testing_Layer.py
	Used to perform Super Resolution via the CNNs. 
	Each file specifies the layer. For x4 upscaling, this is specified in the file name.
	The script is designed to iterate over all images in a folder
	Images are normalized to the range [0,1] by the script
	It also displays the time it takes to perform the upscaling

	Inputs to the Script:
		1 - LR Images Folder Path
		2 - Motion Compensated Images Folder Path	(Note, corresponding images must have the same file name)
		3 - Path to Folder where HR images will be stored

	Specify in the script:
		weights_path 		= Specify which weights to use to upscale

-Main_Script.sh
	This makes use of the Testing scripts in the previous point and Image_Upsample in Dissertation_Code.
	Thus, it is used to upscale for all the dowscaled, compresssed frames.
	It also makes use of Dissertation_Code/Image_Metrics to obtain the metrics between the upscaled
	and padded images.

-Main_Script_EL.sh
	Gets the EL and adds it to the upscaled frames. To do this, it uses Dissertation_Code/Get_Enhancement_Layer
	and Dissertation_Code/Add_Enhancement_Layer. 
	It then uses Dissertation_Code/Image_Metrics to obtain the new metrics

-Weights Folder
	Contains the trained weights used for each structure

-----------------------------------------------------------------------
Dissertation_Datasets/Data_Pre-Processing
-----------------------------------------------------------------------
This folder contains scripts that handle the pre-processing steps of the data
before it is used to train/validate the networks and before it used for testing.
They make use of the code in Dissertation_Code.
NOTE: These scripts generally do not take paths as input, but use relative file paths
For this reason, it is important to make sure that their placement is correct.


- 1_BMP_From_DICOM.sh
	Inputs: 	Training, Testing or Validation (Keyword to select the folder, NOT THE PATH)
			Modality (CT or MRI, USED FOR FOLDER NAVIGATION)
			All sets (0) or specific set (1)
			If param3 is set to 1, give the set name

	Outputs:	BMP Files from the DICOM Files

	Use: 		Extracts BMP images from the provided DICOM files. Note that an info.txt
			File is required to be present in the DICOM/ folder, which has the form:
				Window Centre
				Window Width
				Number of Frames to Remove from beginning
				Number of Frames to Remove from end
			The last 2 are used to remove unnecessary frames. The script also creates 
			the necessary file structure.

- 1_BMP_From_Video.sh
	Inputs: 	Training, Testing or Validation (Keyword to select the folder, NOT THE PATH)
			All sets (0) or specific set (1)
			If param2 is set to 1, give the set name

	Outputs:	BMP Files from the Video Files

	Use: 		Extracts BMP images from the provided Video files. Note that the script
			assumes that it must navigate to param1/Ultrasound folder. The script also creates 
			the necessary file structure.

-2_Split_Original.sh
	Inputs: 	Training or Validation (Keyword to select the folder, NOT THE PATH)
			Modality (CT, MRI or Ultrasound,  USED FOR FOLDER NAVIGATION)

	Outputs:	64x64 patches

	Use: 		Splits the Original images into 64x64 patches which will be used for training/validation.
			Makes use of the Image_Patches script in Dissertation_Code.
			NOTE: Padded does not need to be used here, they are only required for the testing.


-3_Subsampling_Patches.sh
	Inputs: 	Training or Validation (Keyword to select the folder, NOT THE PATH)
			Modality (CT, MRI or Ultrasound,  USED FOR FOLDER NAVIGATION)
			Factor (2, 4)

	Outputs:	32x32 or 16x16 patches

	Use: 		Downsamples the patches obtained from 2_Split_Original.sh based on the factor
			chosen. These will be used as the LR input for training/validation.
			Makes use of the Image_Subsample script in Dissertation_Code.

-4_Subsampling_Original.sh
	Inputs: 	Training or Validation (Keyword to select the folder, NOT THE PATH)
			Modality (CT, MRI or Ultrasound,  USED FOR FOLDER NAVIGATION)
			Factor (2, 4)

	Outputs:	32x32 or 16x16 patches

	Use: 		Downsamples the original images based on the factor chosen. These will be used 
			as the LR input for training/validation. Makes use of the Image_Subsample 
			script in Dissertation_Code.


-5_Motion_Compensation.sh
	Inputs: 	Training or Validation (Keyword to select the folder, NOT THE PATH)
			Modality (CT, MRI or Ultrasound,  USED FOR FOLDER NAVIGATION)
			Factor (2, 4)
			Preset: Medium (1), Fast (2), UltraFast(3)

	Outputs:	Motion Compensated Downscaled Frames

	Use: 		Makes use of Disseration_Code/Motion_Compensation to obtain the motion compensated 
			downscaled frames. These will be split and used to train the CNN. The
			preset parameter is passed on to OpenCV's Optical Flow algorithm

-6_Split_MC.sh
	Inputs: 	Training or Validation (Keyword to select the folder, NOT THE PATH)
			Modality (CT, MRI or Ultrasound,  USED FOR FOLDER NAVIGATION)
			Factor (2, 4)

	Outputs:	32x32 or 16x16 patches

	Use: 		Splits the Motion Compensated frames obtained by 5_Motion_Comensation.sh into 
			32x32 or 16x16 patches which will be used for training/validation.
			Makes use of the Image_Patches script in Dissertation_Code.

-7_Generate_Txt_Files.sh
	Inputs: 	Training or Validation (Keyword to select the folder, NOT THE PATH)
			Factor (2, 4)

	Outputs:	3 text files (HR, LR, motion compensated) with a randomly shuffled list of patches

	Use: 		Generates 3 text files (one for HR, LR and MC) containing paths for patches.
			Note all the test files will match (ie, Patch_abc is found in line 123 in 
			HR, LR and MC patch files). These files will be used to generate the HDF5 files
			used for training

-8_Generate_HDF5_files_Training/Validation.py
	Inputs: 	/
	Specify in the script: x2 or x4 paths for training and validation data input and where to store them

	Outputs:	Multiple hdf5 files for training and validation.

	Use: 		Iterates over the text files generated by 7_Generate_Txt_Files.sh and creates hdf5 files
			for training and validation. Note that the patches are filtered (as described by the
			documentation). Note also that the files must then be combined into one by another 
			script.

-Testing_Datasets Folder
	- The scripts found in this folder are similar to the ones already described, but are designed to 
	  work for the Testing Datasets
	- 1_BMP_From_DICOM.sh and 1_BMP_From_Video.sh --> Similar to the ones described above
	- 2_Subsampling_Frames_x2.sh and 2_Subsampling_Frames_x4.sh --> Subsamples the padded frames by 2 and 4
		--> Note: Image_Subsample_Padded script is used for x2 downscaling, to create the padded images
	- 3_Create_Videos.sh 
			Inputs: 	Path to Testing folder
					Modality (CT, MRI, Ultrasound)
					Factor (0, 2, 4; where 0 mean full resolution)

			Outputs:	Videos made from the frames

			Use: 		Generates videos made from the frames defined by the factor parameter.
					Also sets up the necessary file structure.

-----------------------------------------------------------------------
Dissertation_Datasets/Video_Compression
-----------------------------------------------------------------------
This folder contains scripts that deal with compression and decompression.
They make use of the encoder, decoder and config files found in 
Dissertation_Datasets/HEVC.
NOTE: FOR THE COMPRESSION AND DECOMPRESSION SCRIPTS, A TABLE IS SHOWN BELOW TO AID THE USER

- 1_HEVC_Compression.sh
	Inputs: 	Path to Folder containing Testing Sets
			Modality to be used (CT, MRI, Ultrasound)
			QP Value to be used in compression

	Outputs:	Compressed Video, Compressed Bitstream, Compression Log

	Use: 		Performs compression of the medical video for the specified Modality 
			in the specified Testing Folder path using the specified QP. Note that 
			it also sets up the necessary folder structure. This is used for x2, x4 
			and padded video.

- 2_HEVC_Compression_Decompression_Lossless_Padded.sh
	Inputs: 	Path to Folder containing Testing Sets
			Modality to be used (CT, MRI, Ultrasound)

	Outputs:	Compressed Video, Compressed Bitstream, Compression Log, Decompression Log

	Use: 		Performs LOSSLESS compression and decompression of the padded medical video  
			for the specified Modality in the specified Testing Folder path. Note that it 	
 			also sets up the necessary folder structure. For all intents and purposes, this
			is the original video. This is used to obtain certain statistics such as the 
			Compression Ratio and the time taken to compress or decompress 1 frame losslessly

- 3_HEVC_Compression_Lossless_x2_x4.sh
	Inputs: 	Path to Folder containing Testing Sets
			Modality to be used (CT, MRI, Ultrasound)

	Outputs:	Compressed Video, Compressed Bitstream, Compression Log

	Use: 		Performs LOSSLESS compression of the x2 and x4 video for the  specified Modality 	
 			in the specified Testing Folder path. Note that it also sets up the necessary 
			folder structure.

- 4_Extract_Frames.sh
	Inputs: 	Path to Folder containing Testing Sets
			Modality to be used (CT, MRI, Ultrasound)
			QP Value to be used in compression

	Outputs:	Frames of a Video

	Use: 		Extracts the frames from the videos for the modality in the testing folder required,
			for the QP value required. This also creates the necessary file strcutre.

			Note: This is not used for lossless, since the lossless	compression of the medical video 
			will result in the same frames obtained by upscaling, that is, no degredation is introduced 
			and thus there is no need to extract the frames.

- 5_Motion_Compensation_Script.sh
	Inputs: 	Path to Folder containing Testing Sets
			Modality to be used (CT, MRI, Ultrasound)
			Factor for which you want the script to run
			Preset to be used for the Motion Compensation Algorithm (OpenCV)
				1: Medium
				2: Fast
				3: UltraFast
			QP Value for which you want the script to run (for lossless, you would have obtained these from 
				a different file in Dissertation_Datasets/Data_Pre-Processing)

	Outputs:	Motion Compensated Frames

	Use: 		Makes use of Disseration_Code/Motion_Compensation to obtain the motion compensated frames
			for the testing set, modality, scaling factor and qp specified in the arguments. The
			preset parameter is passed on to OpenCV's Optical Flow algorithm


- 6_HEVC_Compression_Decompression_EL.sh
	Inputs: 	Path to Folder containing Testing Sets
			QP Value for which the EL is to be compressed
			Modality to be used (CT, MRI, Ultrasound)

	Outputs:	Compressed Video, Compressed Bitstream, Compression Log, Decompression Log

	Use: 		Performs LOSSLESS compression and decompression of the EL for the  
			specified Modality in the specified Testing Folder path. Note that this is only
			used for ELs of lossy compressed medical video with the specified QP. This is used
			for padded, x2 and x4 medical videos.



- 7_HEVC_Compression_Decompression_EL_Lossless.sh
	Inputs: 	Path to Folder containing Testing Sets
			Modality to be used (CT, MRI, Ultrasound)

	Outputs:	Compressed Video, Compressed Bitstream, Compression Log, Decompression Log

	Use: 		Performs LOSSLESS compression and decompression of the EL for the  
			specified Modality in the specified Testing Folder path. Note that this is only
			used for ELs of losslessly compressed x2 and x4 video post Bicubic or CNN upscaling
			(by script 1_HEVC_Compression_Lossless_x2_x4.sh)

- 8_HEVC_Decompression.sh
	Inputs: 	Path to Folder containing Testing Sets
			Modality to be used (CT, MRI, Ultrasound)
			QP Value to be used in compression

	Outputs:	Decompression Log

	Use: 		Performs decompression of the medical video  for the  specified Modality in the specified 
			Testing Folder path. Note that this is only used for medical videos which were compressed
			lossily (by script 1_HEVC_Compression.sh) (padded, x2 and x4)

- 9_HEVC_Decompression_Lossless.sh
	Inputs: 	Path to Folder containing Testing Sets
			Modality to be used (CT, MRI, Ultrasound)

	Outputs:	Decompression Log

	Use: 		Performs decompression of the losslessly compressed medical video (x2 and x4) 
			for the  specified Modality in the specified Testing Folder path. 
			Note that this is only used for x2 and x4 medical videos which were compressed losslessly 
			(by script 1_HEVC_Compression_Lossless_x2_x4.sh)

	
		Video	||	Compression	||	Decompression
	-----------------------------------------------------------------
	Padded Lossless ||	     2		||	     2
	-----------------------------------------------------------------
	Padded Lossy	||	     1		||	     8
	-----------------------------------------------------------------
	x2, x4 Lossless	||	     3		||	     9
	-----------------------------------------------------------------
	x2, x4 Lossy	||	     1		||	     8



	EL for Video	||	Compression	||	Decompression
	-----------------------------------------------------------------
	Padded Lossless	||	Not Needed	||	Not Needed
	-----------------------------------------------------------------
	Padded Lossy	||	     6		||	     6
	-----------------------------------------------------------------
	x2, x4 Lossless	||	     7		||	     7
	-----------------------------------------------------------------
	x2, x4 Lossy	||	     6		||	     6
