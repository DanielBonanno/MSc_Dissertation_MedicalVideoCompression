#! /bin/bash


#ARGUMENTS: 
#1: Testing Path
#2: Ultrasound, CT, MRI
#3: QP

cd "$1/$2"
sets_dir=$(pwd)

for set in */; do	#Iterate over every set in the directory
	echo $set	
	cd $sets_dir/$set	
	set_name=$(basename "$set")
	
	#Create the necessary file structure and obtain filepaths required
	cd "Compressed/Original/QP$3/Video"
	compressed_original_video="$(pwd)/$set_name.yuv"
	cd "../"
	mkdir -p -m 777 "Frames"
	mkdir -p -m 777 "Frames/Extracted"
	cd "Frames/Extracted"
	frames_original_directory=$(pwd)

	cd $sets_dir/$set	
	cd "Compressed/x2/QP$3/Video"
	compressed_x2_video="$(pwd)/$set_name.yuv"
	cd "../"
	mkdir -p -m 777 "Frames"
	mkdir -p -m 777 "Frames/Extracted"
	cd "Frames/Extracted"
	frames_x2_directory=$(pwd)

	cd $sets_dir/$set	
	cd "Compressed/x4/QP$3/Video"
	compressed_x4_video="$(pwd)/$set_name.yuv"
	cd "../"
	mkdir -p -m 777 "Frames"
	mkdir -p -m 777 "Frames/Extracted"
	cd "Frames/Extracted"
	frames_x4_directory=$(pwd)

		
	#Obtain parameters: width, height, number of frames
	cd "$sets_dir/$set/Uncompressed/BMP/Padded"
	original_width=$(identify -format '%w' $(ls | head -1))
	original_height=$(identify -format '%h' $(ls | head -1))

	cd "$sets_dir/$set/Uncompressed/BMP/x2"
	x2_width=$(identify -format '%w' $(ls | head -1))
	x2_height=$(identify -format '%h' $(ls | head -1))

	cd "$sets_dir/$set/Uncompressed/BMP/x4"
	x4_width=$(identify -format '%w' $(ls | head -1))
	x4_height=$(identify -format '%h' $(ls | head -1))

	#Extract Frames
	ffmpeg -s:v "$original_width"x"$original_height" -pix_fmt gray -loglevel quiet -i $compressed_original_video -pix_fmt gray $frames_original_directory/"$set_name"_%06d.bmp
	ffmpeg -s:v "$x2_width"x"$x2_height" -pix_fmt gray -loglevel quiet -i $compressed_x2_video -pix_fmt gray $frames_x2_directory/"$set_name"_%06d.bmp
	ffmpeg -s:v "$x4_width"x"$x4_height" -pix_fmt gray -loglevel quiet -i $compressed_x4_video -pix_fmt gray $frames_x4_directory/"$set_name"_%06d.bmp
done
