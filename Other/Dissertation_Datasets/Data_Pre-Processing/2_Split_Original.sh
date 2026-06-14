#! /bin/bash


#ARGUMENTS: 
#1: Training, Testing, Validation
#2: CT, MRI, Ultrasound

#EX: ./BMP_FROM_DICOM.sh Training CT
root=$(pwd)

cd "../../Dissertation_Code/Image_Patches"
exe_path=$(pwd)

cd "$root"
cd "../$1/$2"
sets_dir=$(pwd)

for set in */; do	#Iterate over every set in the directory
	echo $set
	cd "$sets_dir/$set/BMP/Original"
	mkdir -p -m 777 "Patches"
	patch_dir="$(pwd)/Patches/"
	cd "FullFrame"
	for bmp_file in *; do	#For every full size  BMP, generate 64x64 patches in /BMP/Original/Patches
		$exe_path/main $bmp_file 64 $patch_dir
	done
done
