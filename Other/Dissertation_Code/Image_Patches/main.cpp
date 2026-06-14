#include <math.h>
#include <fstream>
#include <iostream>
#include <iomanip>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/optflow.hpp>

using namespace std;



int main(int argc, char *argv[])
{
    if(argc != 4)
    {
        cout<< "Must input 3 arguments: Path to input image, patch sizes (64, 32, 16), path to output folder"<<endl;
        return 0;
    }

    int patch_size = atoi(argv[2]);
    if(!((patch_size == 64) || (patch_size==32) || (patch_size==16)))
    {
        cout<< "Patch size is not supported (16 or 32 or 64)"<<endl;
        return -1;
    }

    string input_path = argv[1];
    string output_path = argv[3];

    //Open the images
    cv::Mat input = cv::imread(input_path, CV_LOAD_IMAGE_GRAYSCALE);

    if(input.empty())                      // Check for invalid input
    {
        cout<<"Could not open or find the image at: "<< input_path<< endl ;
        return -1;
    }

    //Get filename of the current image
    size_t found_backslash = input_path.find_last_of("/");
    size_t found_extension = input_path.find_last_of(".");

    string filename = input_path.substr(0,found_extension);
    filename = filename.substr(found_backslash+1);


    //Get input width and height
    int input_width = input.cols;
    int input_height = input.rows;

    //Gnenerate the patches and save them.
    int current_width = 0;
    int current_height = 0;
    int patch_count = 1;
    while(current_width+patch_size <= input_width)
    {
        current_height = 0;
        while(current_height+patch_size <= input_height)
        {
            cv::Mat patch(input, cv::Range(current_height, current_height+patch_size), cv::Range(current_width, current_width+patch_size));

            stringstream full_output_path;
            if (output_path.back() == '/')
            {
                full_output_path<< output_path<<filename<<"_PATCH_"<<setw(6)<<setfill('0')<<patch_count<<".bmp";
            }
            else
            {
                full_output_path<< output_path<<"/"<<filename<<"_PATCH_"<<setw(6)<<setfill('0')<<patch_count<<".bmp";

            }
            if(!cv::imwrite(full_output_path.str(), patch))
            {
                 cout<<"Could not write output: "<< output_path<< ". The folder may not exist!"<< endl;
                 return -1;
            }
            patch_count++;

            current_height+=patch_size;

        }
        current_width+=patch_size;
    }
    return 0;
}
