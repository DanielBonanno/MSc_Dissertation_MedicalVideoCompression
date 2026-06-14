#! /bin/bash


#ARGUMENTS: 
#1: Training, Testing, Validation
#2: Ultrasound, CT, MRI
#3: Factor (2 or 4)


#EX: ./Subsampling_Script.sh Training CT 2
root=$(pwd)

cd "../../Dissertation_Code/Image_Subsample"
exe_path=$(pwd)

cd $root
cd "../$1/$2"
sets_dir=$(pwd)

for set in */; do	#Iterate over every set in the directory
	echo $set
	cd "$sets_dir/$set/BMP/Original/FullFrame"
	frames_dir="$(pwd)"
	cd "../../"
	mkdir -p -m 777 "x$3"
	cd "x$3"
	mkdir "FullFrame"
	subsampled_frames_dir="$(pwd)/FullFrame"
	
	for frame in $frames_dir/*.bmp; do	#for every bmp file
		frame_filename=$(basename "$frame")
		$exe_path/main $frame $subsampled_frames_dir/$frame_filename $3
	done
	
done
