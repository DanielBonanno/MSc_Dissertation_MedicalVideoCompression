#! /bin/bash

#ARGUMENTS: 
#1: Training/Validation
#2: Factor (2 or 4)

cd ../$1
root_dir=$(pwd)

#Iterate over CT, MRI, Ultrasound
#And obtain the files in all the sets for the lists
for modality in */; do
	cd $root_dir/$modality
	modality_dir=$(pwd)

	for set in */; do
		cd $modality_dir/$set/BMP/Original/Patches
		find $(pwd) -type f >> $root_dir/$1_HR.txt
	done
done

cd $root_dir
#while read -r line
#do
# echo "$line"
#done <HR.temp > $1_HR.txt

#rm HR.temp

shuf -o $1_HR.txt <$1_HR.txt

cp $1_HR.txt $1_LR.txt
sed -i "s!Original!x$2!g" $1_LR.txt
cp $1_LR.txt $1_MC.txt
sed -i "s!BMP!Motion_Compensated!g" $1_MC.txt


