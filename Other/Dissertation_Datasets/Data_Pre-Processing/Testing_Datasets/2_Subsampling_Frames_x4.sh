#! /bin/bash


#ARGUMENTS: 
#1: Testing Path
#2: Ultrasound, CT, MRI
#3: Factor (2 or 4)

#MUST USE PADDED SUBSAMPLING TO ENSURE EXACTLY DIVISABLE BY BOTH 2 and 4

root=$1

cd "../../../Dissertation_Code/Image_Subsample"

exe_path=$(pwd)

cd $root
cd "$root/$2"
sets_dir=$(pwd)

for set in */; do	#Iterate over every set in the directory
	echo $set
	cd "$sets_dir/$set/Uncompressed/BMP/"
	cd "Padded"
	frames_dir="$(pwd)"
	cd "../"
	mkdir -p -m 777 "x$3"
	cd "x$3"
	subsampled_frames_dir="$(pwd)"
	
	for frame in $frames_dir/*.bmp; do	#for every bmp file
		frame_filename=$(basename "$frame")
		$exe_path/main $frame $subsampled_frames_dir/$frame_filename $3
	done
	
done
