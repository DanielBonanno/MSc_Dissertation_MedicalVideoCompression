#! /bin/bash

#ARGUMENTS: 
#1:

Keras_Models=$(pwd)

cd "../Testing"
testing_dir=$(pwd)

cd "../../Dissertation_Code/Get_Enhancement_Layer"
get_EL=$(pwd)

cd "../Add_Enhancement_Layer"
add_EL=$(pwd)

cd "../Image_Metrics"
metrics_exe=$(pwd)

cd $testing_dir
for modality in */; do
	echo "----------------------------------------------------------------------------------------------------------------------"
	echo $current_modality
	echo "----------------------------------------------------------------------------------------------------------------------"
	cd $testing_dir/$modality
	current_modality="${PWD##*/}"	
	if [ $current_modality = "HEVC" ]; then
		continue
	fi
	modality_dir=$(pwd)		#Ex: CT

	for set in */; do	
		cd $modality_dir/$set	
		set_dir=$(pwd)		#Ex: CT/Lungs_000001

		echo "----------------------------------------------------------------------------------------------------------------------"
		echo $set
		echo "----------------------------------------------------------------------------------------------------------------------"

		coordinates_file=$set_dir/coordinates

		#Get Uncompressed, HR data
		cd "Uncompressed"
		uncompressed_root=$(pwd)	#Ex:CT/Lungs_000001/Uncompressed
		
		original_images=$uncompressed_root/BMP/Padded  #Used to store the path of the original unsampled, uncompressed frames

		cd $uncompressed_root
		cd "../Compressed"
		compressed_root=$(pwd)

		#Get EL, Add EL and get Metrics for Original, compressed data
		for QP in 24 26 28 30 32 
		do
			echo "----------------------------------------------------------------------------------------------------------------------"
			echo "EL and Metrics for full size, QP:"
			echo $QP
			echo "----------------------------------------------------------------------------------------------------------------------"
					
	
			mkdir -p -m 777 "$compressed_root/Original/QP$QP/Frames/EL_Post_Upscaling"
			mkdir -p -m 777 "$compressed_root/Original/QP$QP/Frames/Image+EL_Post_Upscaling"

			EL_dir="$compressed_root/Original/QP$QP/Frames/EL_Post_Upscaling"
			Image_EL_dir="$compressed_root/Original/QP$QP/Frames/Image+EL_Post_Upscaling"
		
			cd "$compressed_root/Original/QP$QP/Frames/Extracted"
			for Reconstructed_image in  $(pwd)/*.bmp; do
				image_name=$(basename "$Reconstructed_image")
				$get_EL/main $original_images/$current_modality"_"$image_name $Reconstructed_image $coordinates_file $EL_dir/$image_name
				$add_EL/main $Reconstructed_image $EL_dir/$image_name $coordinates_file $Image_EL_dir/$image_name
				$metrics_exe/main $original_images/$current_modality"_"$image_name $Image_EL_dir/$image_name >> $Image_EL_dir/Original_EL_Metrics
			done

		done

		for scale in 2 4 
		do
			echo "----------------------------------------------------------------------------------------------------------------------"
			echo "Scale:"
			echo $scale
			echo "----------------------------------------------------------------------------------------------------------------------"
			for QP in 24 26 28 30 32 
			do
				echo "----------------------------------------------------------------------------------------------------------------------"
				echo "QP:"
				echo $QP
				echo "----------------------------------------------------------------------------------------------------------------------"

				cd $compressed_root/x$scale
				cd "QP$QP/Frames"
				frames=$(pwd)

				#FOR BICUBIC
				mkdir -p -m 777 "Bicubic/EL_Post_Upscaling"
				mkdir -p -m 777 "Bicubic/Image+EL_Post_Upscaling"

				EL_dir=$frames/"Bicubic/EL_Post_Upscaling"
				Image_EL_dir=$frames/"Bicubic/Image+EL_Post_Upscaling"
		
				cd "Bicubic/Images"
				for Reconstructed_image in  $(pwd)/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$get_EL/main $original_images/$current_modality"_"$image_name $Reconstructed_image $coordinates_file $EL_dir/$image_name
					$add_EL/main $Reconstructed_image $EL_dir/$image_name $coordinates_file $Image_EL_dir/$image_name
					$metrics_exe/main $original_images/$current_modality"_"$image_name $Image_EL_dir/$image_name >> $Image_EL_dir/Bicubic_EL_Metrics
				done



				

				cd $compressed_root/x$scale
				cd "QP$QP/Frames"
				cd "CNN/6Layers/Images"

				mkdir -p -m 777 "../EL_Post_Upscaling"
				mkdir -p -m 777 "../Image+EL_Post_Upscaling"

				EL_dir=$frames/"CNN/6Layers/EL_Post_Upscaling"
				Image_EL_dir=$frames/"CNN/6Layers/Image+EL_Post_Upscaling"

				for Reconstructed_image in  $(pwd)/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$get_EL/main $original_images/$current_modality"_"$image_name $Reconstructed_image $coordinates_file $EL_dir/$image_name
					$add_EL/main $Reconstructed_image $EL_dir/$image_name $coordinates_file $Image_EL_dir/$image_name
					$metrics_exe/main $original_images/$current_modality"_"$image_name $Image_EL_dir/$image_name >> $Image_EL_dir/6Layer_EL_Metrics
				done


				cd $compressed_root/x$scale
				cd "QP$QP/Frames"
				cd "CNN/8Layers/Images"

				mkdir -p -m 777 "../EL_Post_Upscaling"
				mkdir -p -m 777 "../Image+EL_Post_Upscaling"

				EL_dir=$frames/"CNN/8Layers/EL_Post_Upscaling"
				Image_EL_dir=$frames/"CNN/8Layers/Image+EL_Post_Upscaling"

				for Reconstructed_image in  $(pwd)/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$get_EL/main $original_images/$current_modality"_"$image_name $Reconstructed_image $coordinates_file $EL_dir/$image_name
					$add_EL/main $Reconstructed_image $EL_dir/$image_name $coordinates_file $Image_EL_dir/$image_name
					$metrics_exe/main $original_images/$current_modality"_"$image_name $Image_EL_dir/$image_name >> $Image_EL_dir/8Layer_EL_Metrics
				done


			cd $compressed_root/x$scale
				cd "QP$QP/Frames"
				cd "CNN/10Layers/Images"

				mkdir -p -m 777 "../EL_Post_Upscaling"
				mkdir -p -m 777 "../Image+EL_Post_Upscaling"

				EL_dir=$frames/"CNN/10Layers/EL_Post_Upscaling"
				Image_EL_dir=$frames/"CNN/10Layers/Image+EL_Post_Upscaling"

				for Reconstructed_image in  $(pwd)/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$get_EL/main $original_images/$current_modality"_"$image_name $Reconstructed_image $coordinates_file $EL_dir/$image_name
					$add_EL/main $Reconstructed_image $EL_dir/$image_name $coordinates_file $Image_EL_dir/$image_name
					$metrics_exe/main $original_images/$current_modality"_"$image_name $Image_EL_dir/$image_name >> $Image_EL_dir/10Layer_EL_Metrics
				done
			done
		done

	done

done
