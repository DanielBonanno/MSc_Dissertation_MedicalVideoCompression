#! /bin/bash

#ARGUMENTS: 
#1:Testing Dir
#2:Modality

root=$(pwd)

cd "$1"
testing_dir=$(pwd)

cd "$1/HEVC/bin"
exe_compress="$(pwd)/TAppEncoderStatic"
exe_decompress="$(pwd)/TAppDecoderStatic"

cd "../"
config_file="$(pwd)/Enhancement_Layer_Config_File.cfg"


cd $testing_dir
for modality in $2 
do
	echo "----------------------------------------------------------------------------------------------------------------------"
	echo $current_modality
	echo "----------------------------------------------------------------------------------------------------------------------"
	cd $testing_dir/$modality
	current_modality="${PWD##*/}"	
	if [ $current_modality = "HEVC" ]; then
		continue
	fi
	modality_dir=$(pwd)		#Ex: CT

	for set in */; do	
		cd $modality_dir/$set	
		set_dir=$(pwd)		#Ex: CT/Lungs_000001

		echo "----------------------------------------------------------------------------------------------------------------------"
		echo $set
		set_name=$(basename $set)
		echo "----------------------------------------------------------------------------------------------------------------------"

		cd "Uncompressed/Upscaled"
		uncompressed_root=$(pwd)


		for scale in 2 4 
		do
			echo "----------------------------------------------------------------------------------------------------------------------"
			echo "Scale:"
			echo $scale
			echo "----------------------------------------------------------------------------------------------------------------------"
			
			#FOR BICUBIC
			cd $uncompressed_root/x$scale
			cd "Bicubic/EL_Post_Upscaling"
		
			el_images=$(pwd)
			number_of_frames=$(ls -1 | wc -l)
			width=$(identify -format '%w' $(ls | head -1))
			height=$(identify -format '%h' $(ls | head -1))


			#EL VIDEO DIRECTORY
			cd "$uncompressed_root/x$scale/Bicubic"
			mkdir -p -m 777 "EL_Video_Bicubic"
			cd "EL_Video_Bicubic"
			el_video_dir=$(pwd)	

			#Create the video
			ffmpeg -framerate 10 -i "$el_images/$2_$(basename "$set")_%06d.bmp" -pix_fmt gray  $(basename "$set").yuv -y
			video=$(basename "$set").yuv
			
			#Set parameters
			compressed_video="$el_video_dir/Compressed_"$set_name".yuv"
			compressed_bitstream="$el_video_dir/$set_name.bit"
			compressed_log="$el_video_dir/$set_name.txt"
			decompressed_log="$el_video_dir/Decompression_"$set_name".txt"

			#Compress
			$exe_compress -c $config_file -i $video -b $compressed_bitstream -o $compressed_video -wdt $width -hgt $height -fr 10 -f $number_of_frames -q 1 >> $compressed_log
		
			#Decompress
			$exe_decompress -b $compressed_bitstream >> $decompressed_log

			#FOR CNNs
			for layers in 6 8 10
			do
				cd $uncompressed_root/x$scale
				cd "CNN/"$layers"Layers/EL_Post_Upscaling"
				el_images=$(pwd)
				number_of_frames=$(ls -1 | wc -l)
				width=$(identify -format '%w' $(ls | head -1))
				height=$(identify -format '%h' $(ls | head -1))


				#EL VIDEO DIRECTORY
				cd "$uncompressed_root/x$scale/CNN/"$layers"Layers"
				mkdir -p -m 777 "EL_Video_CNN"$layers
				cd "EL_Video_CNN"$layers
				el_video_dir=$(pwd)	

				#Create the video
				ffmpeg -framerate 10 -i "$el_images/$2_$(basename "$set")_%06d.bmp" -pix_fmt gray  $(basename "$set").yuv -y
				video=$(basename "$set").yuv

				#Set parameters
				compressed_video="$el_video_dir/Compressed_$set_name.yuv"
				compressed_bitstream="$el_video_dir/$set_name.bit"
				compressed_log="$el_video_dir/$set_name.txt"
				decompressed_log="$el_video_dir/Decompression_$set_name.txt"

				#Compress
				$exe_compress -c $config_file -i $video -b $compressed_bitstream -o $compressed_video -wdt $width -hgt $height -fr 10 -f $number_of_frames -q 1 >> $compressed_log

				#Decompress
				$exe_decompress -b $compressed_bitstream >> $decompressed_log

			done
		done

	done

done
