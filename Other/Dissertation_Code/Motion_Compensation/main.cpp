#include <math.h>
#include <fstream>
#include <iostream>
#include <string>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/optflow.hpp>

using namespace std;

//OUTPUTS: MOTION COMPENSATED FRAME
//NB: EXTENSIONS ARE NOT ASSUMED

int main(int argc, char *argv[])
{
    if(argc != 5)
    {
        cout<< "Must input a paths to: frame 1, frame 2, output frame and Preset (1: Medium, 2: Fast, 3: Ultrafast)!"<<endl;
        return 0;
    }

       string image1_path = argv[1];
       string image2_path = argv[2];
       string output_path = argv[3];
       int preset = atoi(argv[4]);

        //Open the images
        cv::Mat image_1 = cv::imread(image1_path, CV_LOAD_IMAGE_GRAYSCALE);

        if(image_1.empty() )                      // Check for invalid input
        {
            cout<<"Could not open or find the image 1 at: "<< image1_path<< endl ;
            return -1;
        }

        cv::Mat image_2 = cv::imread(image2_path, CV_LOAD_IMAGE_GRAYSCALE);
        if(image_2.empty() )                      // Check for invalid input
        {
            cout<<"Could not open or find the image 2 at: "<< image2_path<< endl ;
            return -1;
        }

        //Perform optical flow
        cv::Ptr<cv::DenseOpticalFlow> algorithm;
        if(preset == 1)
        {
           algorithm = cv::optflow::createOptFlow_DIS(cv::optflow::DISOpticalFlow::PRESET_MEDIUM);

        }else if(preset == 2)
        {
            algorithm = cv::optflow::createOptFlow_DIS(cv::optflow::DISOpticalFlow::PRESET_FAST);

        }else if(preset == 3)
        {
            algorithm = cv::optflow::createOptFlow_DIS(cv::optflow::DISOpticalFlow::PRESET_ULTRAFAST);

        }else
        {
            cout<<"Invalid Preset Value";
            return -1;
        }
        cv::Mat flow;
        cv::Mat flow_uv[2];

        algorithm->calc(image_1, image_2, flow);
        cv::split(flow, flow_uv);   //split it into x and y components

        //Obtain the motion compensated output and save
        int rows = image_1.rows;
        int cols = image_1.cols;
        cv::Mat output = cv::Mat::zeros(cv::Size(cols, rows), image_1.type());
        for(int row = 0; row < rows; row++)
        {
            for(int col = 0; col< cols; col++)
            {
                output.at<uchar>(row,col) = image_1.at<uchar>(row-round(flow_uv[1].at<float>(row,col)),col-round(flow_uv[0].at<float>(row,col)));
            }
        }

        if(!cv::imwrite(output_path, output))
        {
             cout<<"Could not write output: "<< output_path<< ". The folder may not exist!"<< endl;
             return -1;
        }
    return 0;
}
