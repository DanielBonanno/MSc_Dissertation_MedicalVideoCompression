#include <math.h>
#include <fstream>
#include <iostream>
#include <numeric>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/optflow.hpp>

using namespace std;

float MAE(const cv::Mat& image_1, const cv::Mat& image_2)
{

    cv::Mat tmp(image_1.rows, image_1.cols, CV_32F);
    cv::absdiff(image_1, image_2, tmp);

    return float(cv::mean(tmp).val[0]);
}

float PSNR(const cv::Mat& image_1, const cv::Mat& image_2)
{
    cv::Mat image_1_norm(image_1.rows, image_1.cols, CV_32F);
    cv::Mat image_2_norm(image_2.rows, image_2.cols, CV_32F);
    cv::Mat tmp(image_1.rows, image_1.cols, CV_32F);

    image_1.convertTo(image_1_norm, CV_32F, 1.f/255);
    image_2.convertTo(image_2_norm, CV_32F, 1.f/255);
    cv::subtract(image_1_norm, image_2_norm, tmp);
    cv::multiply(tmp, tmp, tmp);
    return float(10*log10( 1/cv::mean(tmp).val[0] ));
}

float SSIM( const cv::Mat& i1, const cv::Mat& i2)
{
    const double C1 = 6.5025, C2 = 58.5225;
    /***************************** INITS **********************************/
    int d     = CV_32F;

    cv::Mat I1, I2;
    i1.convertTo(I1, d);           // cannot calculate on one byte large values
    i2.convertTo(I2, d);

    cv::Mat I2_2   = I2.mul(I2);        // I2^2
    cv::Mat I1_2   = I1.mul(I1);        // I1^2
    cv::Mat I1_I2  = I1.mul(I2);        // I1 * I2

    /*************************** END INITS **********************************/

    cv::Mat mu1, mu2;   // PRELIMINARY COMPUTING
    cv::GaussianBlur(I1, mu1, cv::Size(11, 11), 1.5);
    cv::GaussianBlur(I2, mu2, cv::Size(11, 11), 1.5);

    cv::Mat mu1_2   =   mu1.mul(mu1);
    cv::Mat mu2_2   =   mu2.mul(mu2);
    cv::Mat mu1_mu2 =   mu1.mul(mu2);

    cv::Mat sigma1_2, sigma2_2, sigma12;

    cv::GaussianBlur(I1_2, sigma1_2, cv::Size(11, 11), 1.5);
    sigma1_2 -= mu1_2;

    cv::GaussianBlur(I2_2, sigma2_2, cv::Size(11, 11), 1.5);
    sigma2_2 -= mu2_2;

    cv::GaussianBlur(I1_I2, sigma12, cv::Size(11, 11), 1.5);
    sigma12 -= mu1_mu2;

    ///////////////////////////////// FORMULA ////////////////////////////////
    cv::Mat t1, t2, t3;

    t1 = 2 * mu1_mu2 + C1;
    t2 = 2 * sigma12 + C2;
    t3 = t1.mul(t2);              // t3 = ((2*mu1_mu2 + C1).*(2*sigma12 + C2))

    t1 = mu1_2 + mu2_2 + C1;
    t2 = sigma1_2 + sigma2_2 + C2;
    t1 = t1.mul(t2);               // t1 =((mu1_2 + mu2_2 + C1).*(sigma1_2 + sigma2_2 + C2))

    cv::Mat ssim_map;
    cv::divide(t3, t1, ssim_map);      // ssim_map =  t3./t1;

    cv::Scalar mssim = cv::mean( ssim_map ); // mssim = average of ssim map
    return mssim.val[0];
}


float SSIM_l( const cv::Mat& i1, const cv::Mat& i2)
{
    const double C1 = 6.5025;
    /***************************** INITS **********************************/
    int d     = CV_32F;

    cv::Mat I1, I2;
    i1.convertTo(I1, d);           // cannot calculate on one byte large values
    i2.convertTo(I2, d);

    /*************************** END INITS **********************************/

    cv::Mat mu1, mu2;   // PRELIMINARY COMPUTING
    cv::GaussianBlur(I1, mu1, cv::Size(11, 11), 1.5);
    cv::GaussianBlur(I2, mu2, cv::Size(11, 11), 1.5);

    cv::Mat mu1_2   =   mu1.mul(mu1);
    cv::Mat mu2_2   =   mu2.mul(mu2);
    cv::Mat mu1_mu2 =   mu1.mul(mu2);


    ///////////////////////////////// FORMULA ////////////////////////////////
    cv::Mat t1_numerator, t1_denominator;

    t1_numerator = 2 * mu1_mu2 + C1;
    t1_denominator = mu1_2 + mu2_2 + C1;

    cv::Mat ssim_map;
    cv::divide(t1_numerator, t1_denominator, ssim_map);      // ssim_map =  t3./t1;

    cv::Scalar mssim_cs = cv::mean( ssim_map ); // mssim = average of ssim map
    return mssim_cs.val[0];
}

float SSIM_cs( const cv::Mat& i1, const cv::Mat& i2)
{
    const double C2 = 58.5225;
    /***************************** INITS **********************************/
    int d     = CV_32F;

    cv::Mat I1, I2;
    i1.convertTo(I1, d);           // cannot calculate on one byte large values
    i2.convertTo(I2, d);

    cv::Mat I2_2   = I2.mul(I2);        // I2^2
    cv::Mat I1_2   = I1.mul(I1);        // I1^2
    cv::Mat I1_I2  = I1.mul(I2);        // I1 * I2

    /*************************** END INITS **********************************/

    cv::Mat mu1, mu2;   // PRELIMINARY COMPUTING
    cv::GaussianBlur(I1, mu1, cv::Size(11, 11), 1.5);
    cv::GaussianBlur(I2, mu2, cv::Size(11, 11), 1.5);

    cv::Mat mu1_2   =   mu1.mul(mu1);
    cv::Mat mu2_2   =   mu2.mul(mu2);
    cv::Mat mu1_mu2 =   mu1.mul(mu2);

    cv::Mat sigma1_2, sigma2_2, sigma12;

    cv::GaussianBlur(I1_2, sigma1_2, cv::Size(11, 11), 1.5);
    sigma1_2 -= mu1_2;

    cv::GaussianBlur(I2_2, sigma2_2, cv::Size(11, 11), 1.5);
    sigma2_2 -= mu2_2;

    cv::GaussianBlur(I1_I2, sigma12, cv::Size(11, 11), 1.5);
    sigma12 -= mu1_mu2;

    ///////////////////////////////// FORMULA ////////////////////////////////
    cv::Mat t2_numerator, t2_denominator;

    t2_numerator = 2 * sigma12 + C2;

    t2_denominator = sigma1_2 + sigma2_2 + C2;

    cv::Mat ssim_map;
    cv::divide(t2_numerator, t2_denominator, ssim_map);      // ssim_map =  t3./t1;

    cv::Scalar mssim_l = cv::mean( ssim_map ); // mssim = average of ssim map
    return mssim_l.val[0];
}


float MSSSIM(const cv::Mat& i1, const cv::Mat& i2)
{
    float weight[5] = {0.0448, 0.2856, 0.3001, 0.2363, 0.1333};
    float cs[5];
    int d     = CV_32F;

    cv::Mat I1, I2;
    i1.convertTo(I1, d);
    i2.convertTo(I2, d);

    for (int i = 0; i <5; i++)
    {
        cs[i] = SSIM_cs(I1, I2);
        cv::GaussianBlur(I1, I1, cv::Size(3, 3), 0.5, 0.5,cv::BORDER_REPLICATE);
        cv::GaussianBlur(I2, I2, cv::Size(3, 3), 0.5, 0.5,cv::BORDER_REPLICATE);
        int width = I1.cols;
        int height = I1.rows;

        if(i!=4)
        {
            cv::resize(I2, I2, cv::Size(width/2, height/2), cv::INTER_CUBIC);
            cv::resize(I1, I1, cv::Size(width/2, height/2), cv::INTER_CUBIC);

        }



    }
    float l = SSIM_l(I1, I2);
    return pow(l, weight[4])* pow(cs[0], weight[0]) * pow(cs[1], weight[1]) * pow(cs[2], weight[2]) * pow(cs[3], weight[3]) * pow(cs[4], weight[4]);
}

int main(int argc, char *argv[])
{
    if(argc != 3)
    {
        cout<< "Must input 2 arguments: Path to input image 1, path to input image 2"<<endl;
        return 0;
    }


    string input_path_1 = argv[1];
    string input_path_2 = argv[2];

    //Open the images
    cv::Mat input_1 = cv::imread(input_path_1, CV_LOAD_IMAGE_GRAYSCALE);
    cv::Mat input_2 = cv::imread(input_path_2, CV_LOAD_IMAGE_GRAYSCALE);

    if(input_1.empty())                      // Check for invalid input
    {
        cout<<"Could not open or find the image at: "<< input_path_1<< endl ;
        return -1;
    }

    if(input_2.empty())                      // Check for invalid input
    {
        cout<<"Could not open or find the image at: "<< input_path_2<< endl ;
        return -1;
    }

    cout<<MAE(input_1, input_2)<<","<<PSNR(input_1, input_2)<<","<<SSIM(input_1, input_2)<<","<<MSSSIM(input_1, input_2)<<"\n";


    return 0;
}
