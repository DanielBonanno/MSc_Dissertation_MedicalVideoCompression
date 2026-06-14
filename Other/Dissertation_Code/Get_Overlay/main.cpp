#include <math.h>
#include <fstream>
#include <iostream>
#include <string>


#include <opencv2/highgui/highgui.hpp>
#include <opencv2/optflow.hpp>

using namespace std;

int main(int argc, char *argv[])
{
    if(argc != 4)
    {
        cout<< "Must input 3 arguments: Path to single image (to get size),path for ROI co-oridinates and path for where to save overlay"<<endl;
        return 0;
    }

    string original_path = argv[1];
    string coordinate_path = argv[2];
    string output_path = argv[3];


    cv::Mat original_image = cv::imread(original_path, CV_LOAD_IMAGE_GRAYSCALE);

    if(original_image.empty())                      // Check for invalid input
    {
        cout<<"Could not open or find the image at: "<< original_path<< endl ;
        return -1;
    }

    int width = original_image.cols;
    int height = original_image.rows;

    ifstream coordinateFile;
    //co-ordinates for top left and bottomright corners (width, height)
    int top_left[2];
    int width_ROI, height_ROI;


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
    top_left[0] -= 2;
    top_left[1] = atoi(temp_2.c_str());
    top_left[1] -= 2;

    width_ROI = atoi(temp_3.c_str());
    width_ROI += 4;
    height_ROI = atoi(temp_4.c_str());
    height_ROI += 4;

    coordinateFile.close();

    cv::Mat overlay = cv::Mat(height, width, CV_8UC4, cv::Scalar(0,0,0,0));
    cv::line(overlay,cv::Point(top_left[0], top_left[1]),cv::Point(top_left[0]+width_ROI, top_left[1]),cv::Scalar(0,0,255,255),2);
    cv::line(overlay,cv::Point(top_left[0], top_left[1]),cv::Point(top_left[0], top_left[1]+height_ROI),cv::Scalar(0,0,255,255),2);
    cv::line(overlay,cv::Point(top_left[0]+width_ROI, top_left[1]+height_ROI),cv::Point(top_left[0]+width_ROI, top_left[1]),cv::Scalar(0,0,255,255),2);
    cv::line(overlay,cv::Point(top_left[0]+width_ROI, top_left[1]+height_ROI),cv::Point(top_left[0], top_left[1]+height_ROI),cv::Scalar(0,0,255,255),2);



    if(!cv::imwrite(output_path, overlay))
    {
         cout<<"Could not write output: "<< output_path<< ". The folder may not exist!"<< endl;
         return -1;
    }
    return 0;
}
