#! /bin/bash


#ARGUMENTS: 
#1: Testing Path
#2: Ultrasound, CT, MRI
#3: Factor (0, 2 or 4)

cd "$1/$2"
sets_dir=$(pwd)

for set in */; do	#Iterate over every set in the directory
	echo $set
	cd "$sets_dir/$set/Uncompressed/BMP/"
	if [ $3 -eq 0 ]
	then
		cd "Padded"
	else
		cd "x$3"
	fi
	frames_dir="$(pwd)"
	cd "../../"
	mkdir -p -m 777 "Video"
	if [ $3 -eq 0 ]
	then
		mkdir -p -m 777 "Video/Padded"
		cd "Video/Padded"
	else
		mkdir -p -m 777 "Video/x$3"
		cd "Video/x$3"
	fi
	video_dir="$(pwd)"
	ffmpeg -y -framerate 10 -i "$frames_dir/$2_$(basename "$set")_%06d.bmp" -pix_fmt gray  $(basename "$set").yuv
	
done
