#! /bin/bash


#ARGUMENTS: 
#1: Testing Path
#2: Ultrasound, CT, MRI
#3: QP

cd "$1/HEVC/bin"
echo $(pwd)
exe_decompress="$(pwd)/TAppDecoderStatic"

cd "$1/$2"
sets_dir=$(pwd)

for set in */; do	#Iterate over every set in the directory
	echo $set	
	cd $sets_dir/$set	
	set_name=$(basename "$set")
	
	cd "Compressed/Original/QP$3/Video"
	compressed_bitstream="$(pwd)/$set_name.bit"
	decompressed_log="$(pwd)/Decompression_$set_name.txt"
	$exe_decompress -b $compressed_bitstream >> $decompressed_log

	cd $sets_dir/$set
	cd "Compressed/x2/QP$3/Video"
	compressed_bitstream="$(pwd)/$set_name.bit"
	decompressed_log="$(pwd)/Decompression_$set_name.txt"
	$exe_decompress -b $compressed_bitstream >> $decompressed_log

	cd $sets_dir/$set
	cd "Compressed/x4/QP$3/Video"
	compressed_bitstream="$(pwd)/$set_name.bit"
	decompressed_log="$(pwd)/Decompression_$set_name.txt"
	$exe_decompress -b $compressed_bitstream >> $decompressed_log
done
