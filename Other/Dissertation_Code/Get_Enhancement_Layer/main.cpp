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
        cout<< "Must input 4 arguments: Path to original image, path to distorted image, path for ROI co-oridinates and path for where to save EL"<<endl;
        return 0;
    }

    string original_path = argv[1];
    string distorted_path = argv[2];
    string coordinate_path = argv[3];
    string output_path = argv[4];


    cv::Mat original_image = cv::imread(original_path, CV_LOAD_IMAGE_GRAYSCALE);
    cv::Mat distorted_image = cv::imread(distorted_path, CV_LOAD_IMAGE_GRAYSCALE);

    cv::Mat original_ROI;
    cv::Mat distorted_ROI;
    ifstream coordinateFile;

    //co-ordinates for top left and width, height)
    int top_left[2];
    int width_ROI, height_ROI;

    //--------------------------------Read Images------------------------------------
    if(original_image.empty())                      // Check for invalid input
    {
        cout<<"Could not open or find the image at: "<< original_path<< endl ;
        return -1;
    }

    if(distorted_image.empty())                      // Check for invalid input
    {
        cout<<"Could not open or find the image at: "<< distorted_path<< endl ;
        return -1;
    }


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

    original_ROI    = original_image(cv::Rect(top_left[0], top_left[1], width_ROI,  height_ROI));
    distorted_ROI   = distorted_image(cv::Rect(top_left[0], top_left[1], width_ROI,  height_ROI));

    original_ROI.convertTo(original_ROI, CV_32S);
    distorted_ROI.convertTo(distorted_ROI, CV_32S);


    cv::Mat ROI_difference(cv::Size(width_ROI, height_ROI), CV_32S);
    cv::subtract(original_ROI,distorted_ROI,ROI_difference);


    ROI_difference+=128;

    ROI_difference.convertTo(ROI_difference, CV_8U);

    if(!cv::imwrite(output_path, ROI_difference))
    {
         cout<<"Could not write output: "<< output_path<< ". The folder may not exist!"<< endl;
         return -1;
    }
    return 0;
}
