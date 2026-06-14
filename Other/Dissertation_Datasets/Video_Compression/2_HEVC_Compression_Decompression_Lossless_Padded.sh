#! /bin/bash


#ARGUMENTS: 
#1: Testing Path
#2: Ultrasound, CT, MRI

cd "$1/HEVC/bin"
exe="$(pwd)/TAppEncoderStatic"
exe_decompress="$(pwd)/TAppDecoderStatic"

cd "../"
config_file="$(pwd)/Enhancement_Layer_Config_File.cfg"

cd "$1/$2"
sets_dir=$(pwd)

for set in */; do	#Iterate over every set in the directory
	echo $set	
	cd $sets_dir/$set	
	set_name=$(basename "$set")
	
	#Obtain the video to be compressed	
	cd "$sets_dir/$set/Uncompressed/Video/Padded"
	original_video="$(pwd)/$set_name.yuv"
	compressed_original_video="$(pwd)/"Compressed_"$set_name.yuv"
	compressed_original_bitstream="$(pwd)/$set_name.bit"
	compressed_original_log="$(pwd)/$set_name.txt"
	decompressed_log="$(pwd)/Decompression_$set_name.txt"
	
	#Obtain parameters: width, height, number of frames
	cd "$sets_dir/$set/Uncompressed/BMP/Padded"
 	number_of_frames=$(ls -1 | wc -l)
	original_width=$(identify -format '%w' $(ls | head -1))
	original_height=$(identify -format '%h' $(ls | head -1))


	#Perform lossless compression of the padded video
	$exe -c $config_file -i $original_video -b $compressed_original_bitstream -o $compressed_original_video -wdt $original_width -hgt $original_height -fr 10 -f $number_of_frames >> $compressed_original_log


	$exe_decompress -b $compressed_original_bitstream >> $decompressed_log

done
