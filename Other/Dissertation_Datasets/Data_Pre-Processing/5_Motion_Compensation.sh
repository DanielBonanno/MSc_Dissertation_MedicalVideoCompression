#! /bin/bash


#ARGUMENTS: 
#1: Training, Testing, Validation
#2: Ultrasound, CT, MRI
#3: Factor (2 or 4)
#4: Preset: Medium (1), Fast (2), UltraFast(3)


#EX: ./Motion_Compensation_Script.sh Training CT 2
root=$(pwd)

cd "../../Dissertation_Code/Motion_Compensation"
exe_path=$(pwd)

cd "$root"
cd "../$1/$2"
sets_dir=$(pwd)


for set in */; do	#Iterate over every set in the directory		
	echo $set
	cd "$sets_dir/$set"		
	current_set_BMP_dir="BMP/x$3/FullFrame"		
	
	mkdir -p -m 777 "Motion_Compensated"
	mkdir -p -m 777 "Motion_Compensated/x$3"
	mkdir -p -m 777 "Motion_Compensated/x$3/FullFrame"

	MC_dir="$(pwd)/Motion_Compensated/x$3/FullFrame"


	for bmp_file in $(ls ./$current_set_BMP_dir/*.bmp | sort -g) ; do	#for every bmp file			
		bmp_file_name=$(basename "$bmp_file")			#CT_Set1_000001.bmp (keep just the filename (no path))
		bmp_file_number_extension=${bmp_file_name: -10}		#000001.bmp (keep last 10)
		bmp_file_number=${bmp_file_number_extension%.*}		#000001 (remove extension)

		if [ "$bmp_file_number" == "000001" ]
		then
			$exe_path/main $bmp_file $bmp_file $MC_dir/$bmp_file_name $4
		else
			bmp_previous_file_number=$(printf "%06d" "$(( $((10#$bmp_file_number))-1))")	#Obtain previous file's number (zero padded)
			bmp_previous_file_name="$2_${set%?}_$bmp_previous_file_number.bmp"		#Construct the name of the previous file
			$exe_path/main $current_set_BMP_dir/$bmp_previous_file_name $bmp_file $MC_dir/$bmp_file_name $4
		fi


	done

	
done


