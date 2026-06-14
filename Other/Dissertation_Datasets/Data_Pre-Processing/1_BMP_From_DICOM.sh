#! /bin/bash


#ARGUMENTS: 
#1: Training, Testing, Validation
#2: CT, MRI
#3: All sets (0), specific set(1)
#4: Name

#EX: ./BMP_FROM_DICOM.sh Training CT 0 or ./BMP_FROM_DICOM.sh Training CT 1 Set2
root=$(pwd)

cd "../$1/$2"
sets_dir=$(pwd)


if [ $3 -eq 0 ]			#If the 3rd parameter is 0
then
	for set in */; do	#Iterate over every set in the directory
		echo $set
		cd "$sets_dir/$set"
		current_set_dir=$(pwd)
		dicom_dir="$current_set_dir/DICOM"

		line=0;
		
		while read p; do		#Read parameters from info.txt
		  info_file[$line]=$p
		  line=$(($line+1));
		done <"$dicom_dir/info.txt"

		#set_name=${set%?}

		mkdir -p -m 777 "BMP"
		mkdir -p -m 777 "BMP/Original"
		mkdir -p -m 777 "BMP/Original/FullFrame"
		bmp_dir="$(pwd)/BMP/Original/FullFrame"

		
		for dicom_file in $dicom_dir/*.dcm; do	#for every dicom file
			bmp_filename=$(echo $(dcmdump +P "0020,0013" $dicom_file) | cut -d "[" -f2 | cut -d "]" -f1)	#extract the instance number	
			bmp_filename_padded=$(printf "%06d" $bmp_filename)

			window_centre=$(echo ${info_file[0]})	#read and transform to integer
			window_centre=${window_centre%?}

			window_width=$(echo ${info_file[1]})
			window_width=${window_width%?}

			if [ $window_centre -eq 0 ]
			then
				window_centre=$(echo $(dcmdump +P "0028,1050" $dicom_file) | cut -d "[" -f2 | cut -d "]" -f1)	#extract the window width				
				window_width=$(echo $(dcmdump +P "0028,1051" $dicom_file) | cut -d "[" -f2 | cut -d "]" -f1)	#extract the window centre

				if [[ $window_centre == *"\\"* ]]; then
				  window_centre=$(echo $window_centre | cut -d "\\" -f1)
				  window_width=$(echo $window_width | cut -d "\\" -f1)
				fi
			fi

			dcmj2pnm $dicom_file +Ww $window_centre $window_width +ob +G "$bmp_dir/$2_${set%?}_$bmp_filename_padded.bmp"		#save the dicom file as: Type_SetName_InstnanceNumber (Type = CT, MRI)
		done

		remove_beginning=$(echo ${info_file[2]})
		remove_beginning=${remove_beginning%?}
		remove_end=$(echo ${info_file[3]})
		remove_end=${remove_end%?}

		#Rename files in numerical order (some dicom data files do not start from 1)
		cd $bmp_dir
		counter=1;
		for bmp in $(ls *.bmp | sort -g) ; do	#for every bmp file created
			bmp_file_name=$(basename "$bmp")			#CT_Set1_000001.bmp (keep just the filename (no path))
			bmp_file_number_extension=${bmp_file_name: -10}		#000001.bmp (keep last 10)
			bmp_file_number=${bmp_file_number_extension%.*}		#000001	(remove extension)


			bmp_filename_padded=$(printf "%06d" $counter)
			new_bmp_filename="$2_${set%?}_$bmp_filename_padded.bmp"
			mv $bmp $new_bmp_filename
			counter=$(($counter+1));
		done

		#Remove frames from the beginning (as specified by info.txt)
		cd $bmp_dir
		for bmp in *.bmp; do	#for every bmp file created
			bmp_file_name=$(basename "$bmp")			#CT_Set1_000001.bmp (keep just the filename (no path))
			bmp_file_number_extension=${bmp_file_name: -10}		#000001.bmp (keep last 10)
			bmp_file_number=${bmp_file_number_extension%.*}		#000001	(remove extension)

			if [ $((10#$bmp_file_number)) -lt $(( $((10#$remove_beginning))+1)) ]
			then
				rm $bmp			
			fi	
		done

		#Remove frames from the end (as specified by info.txt) (UNLESS IT IS 0 or -ve => DO NOT REMOVE ANYTING FROM THE END)
		cd $bmp_dir
		if [ $((10#$remove_end)) -gt 0 ]
		then
			for bmp in *.bmp; do	#for every bmp file created
				bmp_file_name=$(basename "$bmp")			#CT_Set1_000001.bmp (keep just the filename (no path))
				bmp_file_number_extension=${bmp_file_name: -10}		#000001.bmp (keep last 10)
				bmp_file_number=${bmp_file_number_extension%.*}		#000001	(remove extension)

				if [ $((10#$bmp_file_number)) -gt $(( $((10#$remove_end))-1)) ]
				then
					rm $bmp			
				fi	
			done
		fi

		#Rename files in numerical order
		cd $bmp_dir
		counter=1
		for bmp in $(ls *.bmp | sort -g) ; do	#for every bmp file created
			bmp_file_name=$(basename "$bmp")			#CT_Set1_000001.bmp (keep just the filename (no path))
			bmp_file_number_extension=${bmp_file_name: -10}		#000001.bmp (keep last 10)
			bmp_file_number=${bmp_file_number_extension%.*}		#000001	(remove extension)


			bmp_filename_padded=$(printf "%06d" $counter)
			new_bmp_filename="$2_${set%?}_$bmp_filename_padded.bmp"
			mv $bmp $new_bmp_filename
			counter=$(($counter+1));
		done


		
	done
else	#Otherwise, take the set name as input and perform it on that set only
	cd "$sets_dir/$4"
	current_set_dir=$(pwd)
	dicom_dir="$current_set_dir/DICOM"

	#set_name=${set%?}

	line=0;
	while read p; do		#Read parameters from info.txt
	  info_file[$line]=$p
	  line=$(($line+1));
	done <"$dicom_dir/info.txt"	

	mkdir -p -m 777 "BMP"
	bmp_dir="$(pwd)/BMP"


	for dicom_file in /$dicom_dir/*.dcm; do	#for every dicom file
		bmp_filename=$(echo $(dcmdump +P "0020,0013" $dicom_file) | cut -d "[" -f2 | cut -d "]" -f1)	#extract the instance number

		bmp_filename_padded=$(printf "%06d" $bmp_filename)	

		window_centre=$(echo ${info_file[0]})	#read and transform to integer
		window_centre=${window_centre%?}

		window_width=$(echo ${info_file[1]})
		window_width=${window_width%?}

		if [ $window_centre -eq 0 ]
		then
			window_centre=$(echo $(dcmdump +P "0028,1050" $dicom_file) | cut -d "[" -f2 | cut -d "]" -f1)	#extract the window width				
			window_width=$(echo $(dcmdump +P "0028,1051" $dicom_file) | cut -d "[" -f2 | cut -d "]" -f1)	#extract the window centre

			if [[ $window_centre == *"\\"* ]]; then
			  window_centre=$(echo $window_centre | cut -d "\\" -f1)
			  window_width=$(echo $window_width | cut -d "\\" -f1)
			fi
		fi
		dcmj2pnm $dicom_file +Ww $window_centre $window_width +ob +G "$bmp_dir/$2_$4_$bmp_filename_padded.bmp"		#save the dicom file as: Type_SetName_InstnanceNumber (Type = CT, MRI)
	done

	remove_beginning=$(echo ${info_file[2]})
	remove_beginning=${remove_beginning%?}
	remove_end=$(echo ${info_file[3]})
	remove_end=${remove_end%?}

	#Rename files in numerical order (some dicom data files do not start from 1)
	cd $bmp_dir
	counter=1;
	for bmp in $(ls *.bmp | sort -g) ; do	#for every bmp file created
		bmp_file_name=$(basename "$bmp")			#CT_Set1_000001.bmp (keep just the filename (no path))
		bmp_file_number_extension=${bmp_file_name: -10}		#000001.bmp (keep last 10)
		bmp_file_number=${bmp_file_number_extension%.*}		#000001	(remove extension)


		bmp_filename_padded=$(printf "%06d" $counter)
		new_bmp_filename="$2_${set%?}_$bmp_filename_padded.bmp"
		mv $bmp $new_bmp_filename
		counter=$(($counter+1));
	done

	#Remove frames from the beginning (as specified by info.txt)
	cd $bmp_dir
	for bmp in *.bmp; do	#for every bmp file created
		bmp_file_name=$(basename "$bmp")			#CT_Set1_000001.bmp (keep just the filename (no path))
		bmp_file_number_extension=${bmp_file_name: -10}		#000001.bmp (keep last 10)
		bmp_file_number=${bmp_file_number_extension%.*}		#000001	(remove extension)

		if [ $((10#$bmp_file_number)) -lt $(( $((10#$remove_beginning))+1)) ]
		then
			rm $bmp			
		fi	
	done
	
	#Remove frames from the end (as specified by info.txt) (UNLESS IT IS 0 or -ve => DO NOT REMOVE ANYTING FROM THE END)
	cd $bmp_dir
	if [ $((10#$remove_end)) -gt 0 ]
	then
		for bmp in *.bmp; do	#for every bmp file created
			bmp_file_name=$(basename "$bmp")			#CT_Set1_000001.bmp (keep just the filename (no path))
			bmp_file_number_extension=${bmp_file_name: -10}		#000001.bmp (keep last 10)
			bmp_file_number=${bmp_file_number_extension%.*}		#000001	(remove extension)

			if [ $((10#$bmp_file_number)) -gt $(( $((10#$remove_end))-1)) ]
			then
				rm $bmp			
			fi	
		done
	fi

	#Rename files (IF removed from beginning)
	cd $bmp_dir
	counter=1;
	for bmp in $(ls *.bmp | sort -g) ; do	#for every bmp file created
		bmp_file_name=$(basename "$bmp")			#CT_Set1_000001.bmp (keep just the filename (no path))
		bmp_file_number_extension=${bmp_file_name: -10}		#000001.bmp (keep last 10)
		bmp_file_number=${bmp_file_number_extension%.*}		#000001	(remove extension)


		bmp_filename_padded=$(printf "%06d" $counter)
		new_bmp_filename="$2_$4_$bmp_filename_padded.bmp"
		mv $bmp $new_bmp_filename
		counter=$(($counter+1));
	done

fi
