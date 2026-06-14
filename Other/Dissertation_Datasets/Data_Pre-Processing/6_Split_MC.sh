#! /bin/bash


#ARGUMENTS: 
#1: Training, Testing, Validation
#2: CT, MRI, Ultrasound
#3: Scaling Factor

#EX: ./BMP_FROM_DICOM.sh Training CT
root=$(pwd)

cd "../../Dissertation_Code/Image_Patches"
exe_path=$(pwd)

cd "$root"
cd "../$1/$2"
sets_dir=$(pwd)

for set in */; do	#Iterate over every set in the directory
	echo $set
	cd "$sets_dir/$set/Motion_Compensated/x$3"
	mkdir -p -m 777 "Patches"
	patch_dir="$(pwd)/Patches/"
	cd "FullFrame"
	patch_size=$((64/$3))
	for bmp_file in *; do	#For every x2  or X4 MC, generate 32x32 or 16x16 patches in MC/x2orx4/Patches
		$exe_path/main $bmp_file $patch_size $patch_dir
	done
done
