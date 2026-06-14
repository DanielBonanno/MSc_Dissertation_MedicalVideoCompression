#! /bin/bash


#ARGUMENTS: 
#1: Testing Path
#2: Ultrasound, CT, MRI
#3: QP

cd "$1/HEVC/bin"
exe="$(pwd)/TAppEncoderStatic"

cd "../"
config_file="$(pwd)/Medical_Video_Config_File.cfg"

cd "$1/$2"
sets_dir=$(pwd)

for set in */; do	#Iterate over every set in the directory
	echo $set	
	cd $sets_dir/$set	
	set_name=$(basename "$set")
	
	#Create the necessary file structure and obtain filepaths required
	mkdir -p -m 777 "Compressed"
	mkdir -p -m 777 "Compressed/Original"
	mkdir -p -m 777 "Compressed/Original/QP$3"
	mkdir -p -m 777 "Compressed/Original/QP$3/Video"
	cd "Compressed/Original/QP$3/Video"
	compressed_original_video="$(pwd)/$set_name.yuv"
	compressed_original_bitstream="$(pwd)/$set_name.bit"
	compressed_original_log="$(pwd)/$set_name.txt"

	#cd $sets_dir/$set	
	mkdir -p -m 777 "Compressed/x2"
	mkdir -p -m 777 "Compressed/x2/QP$3"
	mkdir -p -m 777 "Compressed/x2/QP$3/Video"
	cd "Compressed/x2/QP$3/Video"
	compressed_x2_video="$(pwd)/$set_name.yuv"
	compressed_x2_bitstream="$(pwd)/$set_name.bit"
	compressed_x2_log="$(pwd)/$set_name.txt"

	#cd $sets_dir/$set	
	mkdir -p -m 777 "Compressed/x4"
	mkdir -p -m 777 "Compressed/x4/QP$3"
	mkdir -p -m 777 "Compressed/x4/QP$3/Video"
	cd "Compressed/x4/QP$3/Video"
	compressed_x4_video="$(pwd)/$set_name.yuv"
	compressed_x4_bitstream="$(pwd)/$set_name.bit"
	compressed_x4_log="$(pwd)/$set_name.txt"

	#Obtain the video to be compressed
	cd "$sets_dir/$set/Uncompressed/Video/Padded"
	original_video="$(pwd)/$set_name.yuv"
	
	cd "$sets_dir/$set/Uncompressed/Video/x2"
	x2_video="$(pwd)/$set_name.yuv"

	cd "$sets_dir/$set/Uncompressed/Video/x4"
	x4_video="$(pwd)/$set_name.yuv"
	
	#Obtain parameters: width, height, number of frames
	cd "$sets_dir/$set/Uncompressed/BMP/Padded"
 	number_of_frames=$(ls -1 | wc -l)
	original_width=$(identify -format '%w' $(ls | head -1))
	original_height=$(identify -format '%h' $(ls | head -1))

	cd "$sets_dir/$set/Uncompressed/BMP/x2"
	x2_width=$(identify -format '%w' $(ls | head -1))
	x2_height=$(identify -format '%h' $(ls | head -1))

	cd "$sets_dir/$set/Uncompressed/BMP/x4"
	x4_width=$(identify -format '%w' $(ls | head -1))
	x4_height=$(identify -format '%h' $(ls | head -1))

	#Perform compression
	$exe -c $config_file -i $original_video -b $compressed_original_bitstream -o $compressed_original_video -wdt $original_width -hgt $original_height -fr 10 -f $number_of_frames -q $3 >> $compressed_original_log
	$exe -c $config_file -i $x2_video -b $compressed_x2_bitstream -o $compressed_x2_video -wdt $x2_width -hgt $x2_height -fr 10 -f $number_of_frames -q $3 >> $compressed_x2_log
	$exe -c $config_file -i $x4_video -b $compressed_x4_bitstream -o $compressed_x4_video -wdt $x4_width -hgt $x4_height -fr 10 -f $number_of_frames -q $3 >> $compressed_x4_log
done
