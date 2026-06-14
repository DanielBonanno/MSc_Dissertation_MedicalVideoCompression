#! /bin/bash


#ARGUMENTS: 
#1: Testing Path
#2: Ultrasound, CT, MRI

cd "$1/HEVC/bin"
exe_decompress="$(pwd)/TAppDecoderStatic"

cd "$1/$2"
sets_dir=$(pwd)

for set in */; do	#Iterate over every set in the directory
	echo $set	
	cd $sets_dir/$set	
	set_name=$(basename "$set")

	cd "Uncompressed/Video/x2/"
	compressed_bitstream="$(pwd)/$set_name.bit"
	decompressed_log="$(pwd)/Decompression_$set_name.txt"
	$exe_decompress -b $compressed_bitstream >> $decompressed_log

	cd $sets_dir/$set
	cd "Uncompressed/Video/x4/"
	compressed_bitstream="$(pwd)/$set_name.bit"
	decompressed_log="$(pwd)/Decompression_$set_name.txt"
	$exe_decompress -b $compressed_bitstream >> $decompressed_log
done
