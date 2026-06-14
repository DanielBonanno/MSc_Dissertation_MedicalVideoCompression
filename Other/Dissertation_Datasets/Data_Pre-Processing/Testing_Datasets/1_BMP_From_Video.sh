#! /bin/bash


#ARGUMENTS: 
#1: Training Dataset Path

root=$1

cd "$1/Ultrasound"
sets_dir=$(pwd)



for set in */; do	#Iterate over every set in the directory
	echo $set
	cd "$sets_dir/$set"
	current_set_dir=$(pwd)
	video_dir="$current_set_dir/Uncompressed/Video/Original_Video"

	
	mkdir -p -m 777 "Uncompressed/BMP"
	mkdir -p -m 777 "Uncompressed/BMP/Original"
	bmp_dir="$(pwd)/Uncompressed/BMP/Original/"

	video_file=$(ls $video_dir)
	ffmpeg -hide_banner -loglevel panic -i $video_dir/$video_file -pix_fmt gray $bmp_dir/Ultrasound_${set%?}_%06d.bmp	
done

