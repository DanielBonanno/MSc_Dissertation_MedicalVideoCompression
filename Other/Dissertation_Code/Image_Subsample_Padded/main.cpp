#include <math.h>
#include <fstream>
#include <iostream>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/optflow.hpp>

using namespace std;


//NOTE: THIS FUNCTION CHANGES THE INPUT IMAGE AS WELL (DUE TO PADDING REQUIRED)

cv::Mat Pad_Image(cv::Mat input_image, int dimension)
{
    //get the width/height (for ease of explanation, we will use width for the rest of the explaination)
    int value = 0;
    if(dimension == 1)
    {
        value = input_image.cols;
    }
    else
    {
        value = input_image.rows;
    }

    //Check the remainder when diving by 4
    float remainder = (float)value/(float)4.0;

    //if the modulo of the remainder is divisable by 8, => BOTH the original and the subsampled width are multiples of 8
    //thus the image does not need any padding
    if (fmod(remainder, 8.0) == 0)
    {
       return input_image;
    }

    //Otherwise, padding is required. To calculate the amount:

    //first get the subsampled width as a multiple of 8
    int new_subsampled_value = remainder - fmod(remainder, 8.0) + 8;

    //obtain the new 'original' width (as a multiple of 8)
    int new_value = new_subsampled_value*4;

    //perform the padding along the width or height
    //ideally padding will be equal to on both sides, but this might not be the case
    int padding = new_value-value;
    if(dimension == 1)
    {
        cv::copyMakeBorder(input_image,input_image,0,0,floor((float)padding/(float)2.0),ceil((float)padding/(float)2.0), cv::BORDER_CONSTANT, cv::Scalar(0));
    }
    else
    {
        cv::copyMakeBorder(input_image,input_image,floor((float)padding/(float)2.0),ceil((float)padding/(float)2.0),0,0, cv::BORDER_CONSTANT, cv::Scalar(0));
    }

    return input_image;
}

int main(int argc, char *argv[])
{
    if(argc != 5)
    {
        cout<< "Must input 4 arguments: Path to input image, path to new padded input image, path to output image and scaling factor (2 or 4)"<<endl;
        return 0;
    }

    int factor = 0;
    if(atoi(argv[4])  == 2)
    {
        factor = 2;
    }else if (atoi(argv[4]) == 4)
    {
        factor = 4;
    }
    else
    {
        cout<< "Scaling Factor not supported. Only supported factors are 2 and 4."<<endl;
        return -1;
    }

    string input_path = argv[1];
    string input_path_new = argv[2];
    string output_path = argv[3];

    //Open the images
    cv::Mat input = cv::imread(input_path, CV_LOAD_IMAGE_GRAYSCALE);

    if(input.empty())                      // Check for invalid input
    {
        cout<<"Could not open or find the image at: "<< input_path<< endl ;
        return -1;
    }


    //Pad the image accordingly such that original width and height and subsampled with and height are both multiplies of 4
    //Note: original width and height must be multiples of 4 such that the subsampling results in exact values
    //      subsampled width and height must be multiples of 4 such that the deconvolution layer upscales the exactly to the original (see working)
    input = Pad_Image(input, 0);
    input = Pad_Image(input, 1);

    if(!cv::imwrite(input_path_new, input))
    {
         cout<<"Could not write output: "<< input_path_new<< ". The folder may not exist!"<< endl;
         return -1;
    }

    cv::GaussianBlur(input, input, cv::Size(5,5), 0.7, 0.7);


    cv::Mat output;
    cv::resize(input, output, cv::Size(), 1.0/float(factor), 1.0/float(factor),cv::INTER_CUBIC);


    if(!cv::imwrite(output_path, output))
    {
         cout<<"Could not write output: "<< output_path<< ". The folder may not exist!"<< endl;
         return -1;
    }
    return 0;
}
