#include <math.h>
#include <fstream>
#include <iostream>
#include <chrono>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/optflow.hpp>

using namespace std;

int main(int argc, char *argv[])
{
    if(argc != 4)
    {
        cout<< "Must input 3 arguments: Path to input image, path to output image and scaling factor (2 or 4)"<<endl;
        return 0;
    }

    int factor = 0;
    if(atoi(argv[3])  == 2)
    {
        factor = 2;
    }else if (atoi(argv[3]) == 4)
    {
        factor = 4;
    }
    else
    {
        cout<< "Scaling Factor not supported. Only supported factors are 2 and 4."<<endl;
        return -1;
    }

    string input_path = argv[1];
    string output_path = argv[2];

    //Open the images
    cv::Mat input = cv::imread(input_path, CV_LOAD_IMAGE_GRAYSCALE);

    if(input.empty())                      // Check for invalid input
    {
        cout<<"Could not open or find the image at: "<< input_path<< endl ;
        return -1;
    }

    //Upsample and Save

    cv::Mat output;

    //Record start time
    auto start = std::chrono::high_resolution_clock::now();
    cv::resize(input, output, cv::Size(), float(factor), float(factor),cv::INTER_CUBIC);
    //Record end time
    auto end = std::chrono::high_resolution_clock::now();

    std::chrono::duration<double> elapsed = end - start;

    std::cout<<"Elapsed time: "<<elapsed.count() <<" s \n";

    if(!cv::imwrite(output_path, output))
    {
         cout<<"Could not write output: "<< output_path<< ". The folder may not exist!"<< endl;
         return -1;
    }
    return 0;
}
