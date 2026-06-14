#! /bin/bash

#ARGUMENTS: 
#1: Testing Dir

Keras_Models=$(pwd)

cd $1
testing_dir=$(pwd)

cd "../../Dissertation_Code/Image_Upsample"
bicubic_exe=$(pwd)

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

		#Get Uncompressed, HR data
		cd "Uncompressed"
		uncompressed_root=$(pwd)	#Ex:CT/Lungs_000001/Uncompressed
		original_images=$uncompressed_root/BMP/Padded  #Used to store the path of the original unsampled, uncompressed frames

		#Run Bicubic and CNNs on Uncompressed, downsampled data
		echo "----------------------------------------------------------------------------------------------------------------------"
		echo "Uncompressed Data"
		echo "----------------------------------------------------------------------------------------------------------------------"
		#mkdir -p -m 777 "Upscaled"

		for scale in 2 4 
		do
			echo "----------------------------------------------------------------------------------------------------------------------"
			echo "Upscaling by" 
			echo $scale
			echo "----------------------------------------------------------------------------------------------------------------------"
			cd $uncompressed_root
			#Set folder hierarchy
	

			mkdir -p -m 777 "Upscaled/x$scale"
			cd "Upscaled/x$scale"

			mkdir -p -m 777 "Bicubic"
			mkdir -p -m 777 "Bicubic/Images"

			cd "Bicubic/Images"
			output_bicubic=$(pwd)
			cd "../../"


			mkdir -p -m 777 "CNN"
			mkdir -p -m 777 "CNN/6Layers"
			mkdir -p -m 777 "CNN/6Layers/Images"

			cd "Upscaled/x$scale"
			cd "CNN/6Layers/Images"
			output_cnn_6=$(pwd)
			cd "../../../"

			mkdir -p -m 777 "CNN/8Layers"
			mkdir -p -m 777 "CNN/8Layers/Images"

			cd "CNN/8Layers/Images"
			output_cnn_8=$(pwd)
			cd "../../../"


			mkdir -p -m 777 "CNN/10Layers"
			mkdir -p -m 777 "CNN/10Layers/Images"

			cd "CNN/10Layers/Images"
			output_cnn_10=$(pwd)
			cd "../../../"


			LR_path=$uncompressed_root/BMP/x$scale   #Ex:CT/Lungs_000001/Uncompressed/BMP/x2
			MC_path=$uncompressed_root/Motion_Compensated/x$scale   #Ex:CT/Lungs_000001/Uncompressed/MC/x2

			#BICUBIC	
			echo "----------------------------------------------------------------------------------------------------------------------"
			echo "BICUBIC"
			echo "----------------------------------------------------------------------------------------------------------------------"
			for LR_image in  $LR_path/*.bmp; do
				image_name=$(basename "$LR_image")
				$bicubic_exe/main $LR_image $output_bicubic/$image_name $scale >> $output_bicubic/Bicubic_time
			done

			for Reconstructed_image in  $output_bicubic/*.bmp; do
				image_name=$(basename "$Reconstructed_image")
				$metrics_exe/main $original_images/$image_name $Reconstructed_image >> $output_bicubic/Bicubic_metrics
			done

			if [ $scale = 2 ]; then
		
				echo "----------------------------------------------------------------------------------------------------------------------"
				echo "CNN 6"
				echo "----------------------------------------------------------------------------------------------------------------------"
			 	python $Keras_Models/Keras_Testing_6Layer.py $LR_path $MC_path $output_cnn_6 >> $output_cnn_6/CNN_6_Time_NEW

				for Reconstructed_image in  $output_cnn_6/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$metrics_exe/main $original_images/$image_name $Reconstructed_image >> $output_cnn_6/CNN_6_metrics_NEW
				done

				echo "----------------------------------------------------------------------------------------------------------------------"
				echo "CNN 8"
				echo "----------------------------------------------------------------------------------------------------------------------"
				python $Keras_Models/Keras_Testing_8Layer.py $LR_path $MC_path $output_cnn_8 >> $output_cnn_8/CNN_8_Time

				for Reconstructed_image in  $output_cnn_8/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$metrics_exe/main $original_images/$image_name $Reconstructed_image >> $output_cnn_8/CNN_8_metrics
				done

				echo "----------------------------------------------------------------------------------------------------------------------"
				echo "CNN 10"
				echo "----------------------------------------------------------------------------------------------------------------------"
				python $Keras_Models/Keras_Testing_10Layer.py $LR_path $MC_path $output_cnn_10 >> $output_cnn_10/CNN_10_Time

				for Reconstructed_image in  $output_cnn_10/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$metrics_exe/main $original_images/$image_name $Reconstructed_image >> $output_cnn_10/CNN_10_metrics
				done
					
			 fi

			if [ $scale = 4 ]; then
				echo "----------------------------------------------------------------------------------------------------------------------"
				echo "CNN 6"
				echo "----------------------------------------------------------------------------------------------------------------------"
			 	python $Keras_Models/Keras_Testing_6Layer_x4.py $LR_path $MC_path $output_cnn_6 >> $output_cnn_6/CNN_6_Time_NEW

				for Reconstructed_image in  $output_cnn_6/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$metrics_exe/main $original_images/$image_name $Reconstructed_image >> $output_cnn_6/CNN_6_metrics_NEW
				done

				echo "----------------------------------------------------------------------------------------------------------------------"
				echo "CNN 8"
				echo "----------------------------------------------------------------------------------------------------------------------"
				python $Keras_Models/Keras_Testing_8Layer_x4.py $LR_path $MC_path $output_cnn_8 >> $output_cnn_8/CNN_8_Time

				for Reconstructed_image in  $output_cnn_8/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$metrics_exe/main $original_images/$image_name $Reconstructed_image >> $output_cnn_8/CNN_8_metrics
				done

				echo "----------------------------------------------------------------------------------------------------------------------"
				echo "CNN 10"
				echo "----------------------------------------------------------------------------------------------------------------------"
				python $Keras_Models/Keras_Testing_10Layer_x4.py $LR_path $MC_path $output_cnn_10 >> $output_cnn_10/CNN_10_Time

				for Reconstructed_image in  $output_cnn_10/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$metrics_exe/main $original_images/$image_name $Reconstructed_image >> $output_cnn_10/CNN_10_metrics
				done
				
			 fi

		done

		cd $uncompressed_root
		cd "../Compressed"
		compressed_root=$(pwd)
		echo "----------------------------------------------------------------------------------------------------------------------"
		echo "Compressed Data"
		echo "----------------------------------------------------------------------------------------------------------------------"

		#Get Metrics for Original, compressed data
		for QP in 24 26 28 30 32 
		do
		echo "----------------------------------------------------------------------------------------------------------------------"
		echo "Metrics for full size, QP:"
		echo $QP
		echo "----------------------------------------------------------------------------------------------------------------------"
			cd "$compressed_root/Original/QP$QP/Frames/Extracted"
			for Reconstructed_image in  $(pwd)/*.bmp; do
				image_name=$(basename "$Reconstructed_image")
				$metrics_exe/main $original_images/$current_modality"_"$image_name $Reconstructed_image >> $(pwd)/Original_Compressed_metrics
			done

		done

		#Apply Bicubic and CNN on downsampled, compressed data

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

				#Set folder hierarchy

				mkdir -p -m 777 "Bicubic"
				mkdir -p -m 777 "Bicubic/Images"

				cd "Bicubic/Images"
				output_bicubic=$(pwd)
				cd "../../"


				mkdir -p -m 777 "CNN"
				mkdir -p -m 777 "CNN/6Layers"
				mkdir -p -m 777 "CNN/6Layers/Images"

				cd "CNN/6Layers/Images"
				output_cnn_6=$(pwd)
				cd "../../../"

				mkdir -p -m 777 "CNN/8Layers"
				mkdir -p -m 777 "CNN/8Layers/Images"

				cd "CNN/8Layers/Images"
				output_cnn_8=$(pwd)
				cd "../../../"


				mkdir -p -m 777 "CNN/10Layers"
				mkdir -p -m 777 "CNN/10Layers/Images"

				cd "CNN/10Layers/Images"
				output_cnn_10=$(pwd)
				cd "../../../"


				LR_path=$frames/Extracted   #Ex:CT/Lungs_000001/Compressed/x2/QP24/Frames/Extracted
				MC_path=$frames/Motion_Compensated   #Ex:CT/Lungs_000001/Uncompressed/MC/x2

				#BICUBIC	
				echo "----------------------------------------------------------------------------------------------------------------------"
				echo "BICUBIC"
				echo "----------------------------------------------------------------------------------------------------------------------"
				for LR_image in  $LR_path/*.bmp; do
					image_name=$(basename "$LR_image")
					$bicubic_exe/main $LR_image $output_bicubic/$image_name $scale >> $output_bicubic/Bicubic_time
				done

				for Reconstructed_image in  $output_bicubic/*.bmp; do
					image_name=$(basename "$Reconstructed_image")
					$metrics_exe/main $original_images/$current_modality"_"$image_name $Reconstructed_image >> $output_bicubic/Bicubic_metrics
				done
			

				 if [ $scale = 2 ]; then
					echo "----------------------------------------------------------------------------------------------------------------------"
					echo "CNN 6"
					echo "----------------------------------------------------------------------------------------------------------------------"
				 	python $Keras_Models/Keras_Testing_6Layer.py $LR_path $MC_path $output_cnn_6 >> $output_cnn_6/CNN_6_Time

					for Reconstructed_image in  $output_cnn_6/*.bmp; do
						image_name=$(basename "$Reconstructed_image")
						$metrics_exe/main $original_images/$current_modality"_"$image_name $Reconstructed_image >> $output_cnn_6/CNN_6_metrics
					done

					echo "----------------------------------------------------------------------------------------------------------------------"
					echo "CNN 8"
					echo "----------------------------------------------------------------------------------------------------------------------"
					python $Keras_Models/Keras_Testing_8Layer.py $LR_path $MC_path $output_cnn_8 >> $output_cnn_8/CNN_8_Time

					for Reconstructed_image in  $output_cnn_8/*.bmp; do
						image_name=$(basename "$Reconstructed_image")
						$metrics_exe/main $original_images/$current_modality"_"$image_name $Reconstructed_image >> $output_cnn_8/CNN_8_metrics
					done

					echo "----------------------------------------------------------------------------------------------------------------------"
					echo "CNN 10"
					echo "----------------------------------------------------------------------------------------------------------------------"
					python $Keras_Models/Keras_Testing_10Layer.py $LR_path $MC_path $output_cnn_10 >> $output_cnn_10/CNN_10_Time

					for Reconstructed_image in  $output_cnn_10/*.bmp; do
						image_name=$(basename "$Reconstructed_image")
						$metrics_exe/main $original_images/$current_modality"_"$image_name $Reconstructed_image >> $output_cnn_10/CNN_10_metrics
					done
					
				 fi

				if [ $scale = 4 ]; then
		
					echo "----------------------------------------------------------------------------------------------------------------------"
					echo "CNN 6"
					echo "----------------------------------------------------------------------------------------------------------------------"
				 	python $Keras_Models/Keras_Testing_6Layer_x4.py $LR_path $MC_path $output_cnn_6 >> $output_cnn_6/CNN_6_Time

					for Reconstructed_image in  $output_cnn_6/*.bmp; do
						image_name=$(basename "$Reconstructed_image")
						$metrics_exe/main $original_images/$current_modality"_"$image_name $Reconstructed_image >> $output_cnn_6/CNN_6_metrics
					done

					echo "----------------------------------------------------------------------------------------------------------------------"
					echo "CNN 8"
					echo "----------------------------------------------------------------------------------------------------------------------"
					python $Keras_Models/Keras_Testing_8Layer_x4.py $LR_path $MC_path $output_cnn_8 >> $output_cnn_8/CNN_8_Time

					for Reconstructed_image in  $output_cnn_8/*.bmp; do
						image_name=$(basename "$Reconstructed_image")
						$metrics_exe/main $original_images/$current_modality"_"$image_name $Reconstructed_image >> $output_cnn_8/CNN_8_metrics
					done

					echo "----------------------------------------------------------------------------------------------------------------------"
					echo "CNN 10"
					echo "----------------------------------------------------------------------------------------------------------------------"
					python $Keras_Models/Keras_Testing_10Layer_x4.py $LR_path $MC_path $output_cnn_10 >> $output_cnn_10/CNN_10_Time

					for Reconstructed_image in  $output_cnn_10/*.bmp; do
						image_name=$(basename "$Reconstructed_image")
						$metrics_exe/main $original_images/$current_modality"_"$image_name $Reconstructed_image >> $output_cnn_10/CNN_10_metrics
					done
					
				 fi
							

			done

		done
	done

done
