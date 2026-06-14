#! /bin/bash


#ARGUMENTS: 
#1: Training, Testing, Validation
#2: All sets (0), specific set(1)
#3: Number if specific set

#EX: ./BMP_FROM_DICOM.sh Training CT 0 or ./BMP_FROM_DICOM.sh Training CT 1 Set2
root=$(pwd)

cd "../$1/Ultrasound"
sets_dir=$(pwd)


if [ $2 -eq 0 ]			#If the 3rd parameter is 0
then
	for set in */; do	#Iterate over every set in the directory
		echo $set
		cd "$sets_dir/$set"
		current_set_dir=$(pwd)
		video_dir="$current_set_dir/Original_Video"


		mkdir -p -m 777 "BMP"
		mkdir -p -m 777 "BMP/Original"
		mkdir -p -m 777 "BMP/Original/FullFrame"
		bmp_dir="$(pwd)/BMP/Original/FullFrame"

		video_file=$(ls $video_dir)
		ffmpeg -hide_banner -loglevel panic -i $video_dir/$video_file -pix_fmt gray $bmp_dir/Ultrasound_${set%?}_%06d.bmp	
	done
else	
	cd "$sets_dir/$3"

	current_set_dir=$(pwd)
	video_dir="$current_set_dir/Original_Video"


	mkdir -p -m 777 "BMP"
	mkdir -p -m 777 "BMP/Original"
	bmp_dir="$(pwd)/BMP/Original"

	video_file=$(ls $video_dir)
	ffmpeg -hide_banner -loglevel panic -i $video_dir/$video_file -pix_fmt gray $bmp_dir/Ultrasound_$3_%06d.bmp

fi
