#! /bin/bash


#ARGUMENTS: 
#1: Testing
#2: Ultrasound, CT, MRI
#3: Factor (2 or 4)
#4: Preset: Medium (1), Fast (2), UltraFast(3)
#5: QP


#EX: ./Motion_Compensation_Script.sh Training CT 2
root=$(pwd)

cd "../../Dissertation_Code/Motion_Compensation"
exe_path=$(pwd)

cd "$root"
cd "$1/$2"
sets_dir=$(pwd)


for set in */; do	#Iterate over every set in the directory		
	echo $set
	cd "$sets_dir/$set/Compressed/x$3/QP$5/Frames/"	
	frames_dir="$(pwd)/Extracted/"		
	
	mkdir -p -m 777 "Motion_Compensated"
	MC_dir="$(pwd)/Motion_Compensated/"


	for bmp_file in $(ls $frames_dir/*.bmp | sort -g) ; do	#for every bmp file			
		bmp_file_name=$(basename "$bmp_file")			#CT_Set1_000001.bmp (keep just the filename (no path))
		bmp_file_number_extension=${bmp_file_name: -10}		#000001.bmp (keep last 10)
		bmp_file_number=${bmp_file_number_extension%.*}		#000001 (remove extension)

		if [ "$bmp_file_number" == "000001" ]
		then
			res1=$(date +%s.%N)
			$exe_path/main $bmp_file $bmp_file $MC_dir/$bmp_file_name $4
			res2=$(date +%s.%N)
			dt=$(echo "$res2 - $res1" | bc)
			dd=$(echo "$dt/86400" | bc)
			dt2=$(echo "$dt-86400*$dd" | bc)
			dh=$(echo "$dt2/3600" | bc)
			dt3=$(echo "$dt2-3600*$dh" | bc)
			dm=$(echo "$dt3/60" | bc)
			ds=$(echo "$dt3-60*$dm" | bc)

			printf "Total runtime: %d:%02d:%02d:%02.8f\n" $dd $dh $dm $ds
		else
			bmp_previous_file_number=$(printf "%06d" "$(( $((10#$bmp_file_number))-1))")	#Obtain previous file's number (zero padded)
			bmp_previous_file_name="${set%?}_$bmp_previous_file_number.bmp"		#Construct the name of the previous file

			res1=$(date +%s.%N)
			$exe_path/main $frames_dir/$bmp_previous_file_name $bmp_file $MC_dir/$bmp_file_name $4
			res2=$(date +%s.%N)
			dt=$(echo "$res2 - $res1" | bc)
			dd=$(echo "$dt/86400" | bc)
			dt2=$(echo "$dt-86400*$dd" | bc)
			dh=$(echo "$dt2/3600" | bc)
			dt3=$(echo "$dt2-3600*$dh" | bc)
			dm=$(echo "$dt3/60" | bc)
			ds=$(echo "$dt3-60*$dm" | bc)

			printf "Total runtime: %d:%02d:%02d:%02.8f\n" $dd $dh $dm $ds
		fi


	done

	
done


