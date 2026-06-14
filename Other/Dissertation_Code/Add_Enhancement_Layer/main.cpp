#include <math.h>
#include <fstream>
#include <iostream>
#include <string>


#include <opencv2/highgui/highgui.hpp>
#include <opencv2/optflow.hpp>

using namespace std;

int main(int argc, char *argv[])
{
    if(argc != 5)
    {
        cout<< "Must input 4 arguments: Path to original image, path to EL image, path for ROI co-oridinates and path for where to save Final Image"<<endl;
        return 0;
    }

    string distorted_path = argv[1];
    string EL_path = argv[2];
    string coordinate_path = argv[3];
    string output_path = argv[4];


    cv::Mat distorted_image = cv::imread(distorted_path, CV_LOAD_IMAGE_GRAYSCALE);
    cv::Mat enhancement_layer = cv::imread(EL_path, CV_LOAD_IMAGE_GRAYSCALE);

    ifstream coordinateFile;

    //co-ordinates for top left corner, width and height)
    int top_left[2];
    int width_ROI, height_ROI;

    //--------------------------------Read Images------------------------------------
    if(distorted_image.empty())                      // Check for invalid input
    {
        cout<<"Could not open or find the image at: "<< distorted_path<< endl ;
        return -1;
    }

    if(enhancement_layer.empty())                      // Check for invalid input
    {
        cout<<"Could not open or find the image at: "<<EL_path << endl ;
        return -1;
    }

    enhancement_layer.convertTo(enhancement_layer, CV_32S);
    enhancement_layer = enhancement_layer - 128;

    //--------------------------------Read Co-Ordinates------------------------------------

    coordinateFile.open(coordinate_path ,std::ifstream::in);
    if (!coordinateFile) {
        cout << "Unable to open co-ordinate file";
        return -1;
    }

    string temp_1, temp_2, temp_3, temp_4;
    std::getline(coordinateFile, temp_1);
    std::getline(coordinateFile, temp_2);
    std::getline(coordinateFile, temp_3);
    std::getline(coordinateFile, temp_4);

    top_left[0] = atoi(temp_1.c_str());
    top_left[1] = atoi(temp_2.c_str());

    width_ROI = atoi(temp_3.c_str());
    height_ROI = atoi(temp_4.c_str());


    coordinateFile.close();

    //--------------------------------Extract ROI from both images ------------------------------------

    //NB: Rect = topleft x, topleft y, width, height

    cv::Mat distorted_ROI   = distorted_image(cv::Rect(top_left[0], top_left[1], width_ROI,  height_ROI));
    distorted_ROI.convertTo(distorted_ROI, CV_32S);
    cv::Mat restored_ROI = distorted_ROI + enhancement_layer;
    restored_ROI.convertTo(restored_ROI, CV_8U);

    restored_ROI.copyTo(distorted_image(cv::Rect(top_left[0], top_left[1], width_ROI,  height_ROI)));

    if(!cv::imwrite(output_path, distorted_image))
    {
         cout<<"Could not write output: "<< output_path<< ". The folder may not exist!"<< endl;
         return -1;
    }
    return 0;
}
