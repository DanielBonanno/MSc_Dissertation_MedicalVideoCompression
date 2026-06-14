#! /bin/bash

#ARGUMENTS: 
#1: Testing Dir
#2: QP
#3: Modality
root=$(pwd)

cd "$1"
testing_dir=$(pwd)

cd "$1/HEVC/bin"
exe_compress="$(pwd)/TAppEncoderStatic"
exe_decompress="$(pwd)/TAppDecoderStatic"

cd "../"
config_file="$(pwd)/Enhancement_Layer_Config_File.cfg"


cd $testing_dir
for modality in $3
do
#*/; do
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
		echo "----------------------------------------------------------------------------------------------------------------------"
		cd "Compressed"
		compressed_root=$(pwd)
		

		#Get EL, Add EL and get Metrics for Original, compressed data
		#for QP in 24 26 28 30 32 
		#do
		QP=$2
 			echo "----------------------------------------------------------------------------------------------------------------------"
			echo "Compressing EL for full size, QP:"
			echo $QP
			echo "----------------------------------------------------------------------------------------------------------------------"
			
			#EL IMAGES DIRECTORY
			cd "Original/QP$QP/Frames/EL_Post_Upscaling"
			el_images=$(pwd)
			number_of_frames=$(ls -1 | wc -l)
			width=$(identify -format '%w' $(ls | head -1))
			height=$(identify -format '%h' $(ls | head -1))

			#EL VIDEO DIRECTORY
			cd "$compressed_root/Original/QP$QP/Video"
			mkdir -p -m 777 "EL_Video_Original"
			cd "EL_Video_Original"
			el_video_dir=$(pwd)	
	
			#Create the video
			ffmpeg -framerate 10 -i "$el_images/$(basename "$set")_%06d.bmp" -pix_fmt gray $(basename "$set").yuv
			video=$(basename "$set").yuv
			
			set_name=$(basename "$set")

			#Set parameters
			compressed_video="$el_video_dir/Compressed_$set_name.yuv"
			compressed_bitstream="$el_video_dir/$set_name.bit"
			compressed_log="$el_video_dir/$set_name.txt"
			decompressed_log="$el_video_dir/Decompression_$set_name.txt"

			#Compress
			$exe_compress -c $config_file -i $video -b $compressed_bitstream -o $compressed_video -wdt $width -hgt $height -fr 10 -f $number_of_frames -q 1 >> $compressed_log

			#Decompress
			$exe_decompress -b $compressed_bitstream >> $decompressed_log
		#done
			
		
		for scale in 2 4 
		do
			echo "----------------------------------------------------------------------------------------------------------------------"
			echo "Scale:"
			echo $scale
			echo "----------------------------------------------------------------------------------------------------------------------"
			#for QP in 24 26 28 30 32 
			#do
			QP=$2
				echo "----------------------------------------------------------------------------------------------------------------------"
				echo "QP:"
				echo $QP
				echo "----------------------------------------------------------------------------------------------------------------------"

				#FOR BICUBIC
				cd $compressed_root/x$scale
				cd "QP$QP/Frames/Bicubic/EL_Post_Upscaling"
				el_images=$(pwd)
				number_of_frames=$(ls -1 | wc -l)
				width=$(identify -format '%w' $(ls | head -1))
				height=$(identify -format '%h' $(ls | head -1))


				#EL VIDEO DIRECTORY
				cd "$compressed_root/x$scale/QP$QP/Video"
				mkdir -p -m 777 "EL_Video_Bicubic"
				cd "EL_Video_Bicubic"
				el_video_dir=$(pwd)	
	
				#Create the video
				ffmpeg -framerate 10 -i "$el_images/$(basename "$set")_%06d.bmp" -pix_fmt gray $(basename "$set").yuv
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



				#FOR CNN6
				cd $compressed_root/x$scale
				cd "QP$QP/Frames/CNN/6Layers/EL_Post_Upscaling"
				el_images=$(pwd)
				number_of_frames=$(ls -1 | wc -l)
				width=$(identify -format '%w' $(ls | head -1))
				height=$(identify -format '%h' $(ls | head -1))


				#EL VIDEO DIRECTORY
				cd "$compressed_root/x$scale/QP$QP/Video"
				mkdir -p -m 777 "EL_Video_CNN6"
				cd "EL_Video_CNN6"
				el_video_dir=$(pwd)	
	
				#Create the video
				ffmpeg -framerate 10 -i "$el_images/$(basename "$set")_%06d.bmp" -pix_fmt gray  $(basename "$set").yuv
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
	
				
				#FOR CNN8
				cd $compressed_root/x$scale
				cd "QP$QP/Frames/CNN/8Layers/EL_Post_Upscaling"
				el_images=$(pwd)
				number_of_frames=$(ls -1 | wc -l)
				width=$(identify -format '%w' $(ls | head -1))
				height=$(identify -format '%h' $(ls | head -1))


				#EL VIDEO DIRECTORY
				cd "$compressed_root/x$scale/QP$QP/Video"
				mkdir -p -m 777 "EL_Video_CNN8"
				cd "EL_Video_CNN8"
				el_video_dir=$(pwd)	
	
				#Create the video
				ffmpeg -framerate 10 -i "$el_images/$(basename "$set")_%06d.bmp" -pix_fmt gray  $(basename "$set").yuv
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



				#FOR CNN10
				cd $compressed_root/x$scale
				cd "QP$QP/Frames/CNN/10Layers/EL_Post_Upscaling"
				el_images=$(pwd)
				number_of_frames=$(ls -1 | wc -l)
				width=$(identify -format '%w' $(ls | head -1))
				height=$(identify -format '%h' $(ls | head -1))


				#EL VIDEO DIRECTORY
				cd "$compressed_root/x$scale/QP$QP/Video"
				mkdir -p -m 777 "EL_Video_CNN10"
				cd "EL_Video_CNN10"
				el_video_dir=$(pwd)	
	
				#Create the video
				ffmpeg -framerate 10 -i "$el_images/$(basename "$set")_%06d.bmp" -pix_fmt gray  $(basename "$set").yuv
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



			#done
		done

	done

done
