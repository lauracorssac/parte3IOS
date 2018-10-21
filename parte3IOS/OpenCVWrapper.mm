//
//  OpenCVWrapper.mm
//  parte3IOS
//
//  Created by Laura Corssac on 16/10/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

#ifdef __cplusplus

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"

#endif

using namespace std;
using namespace cv;

@interface OpenCVWrapper()
#ifdef __cplusplus

+ (Mat)_grayFrom:(Mat)source;
+ (Mat)_matFrom:(UIImage *)source;
+ (UIImage *)_imageFrom:(Mat)source;
+ (Mat)_gaussianFrom:(Mat)source;
+ (Mat)_sobelFrom:(Mat)source;
+ (Mat)_cannyFrom:(Mat)source;
+ (Mat)_adjustFrom:(Mat)source alpha: (double)alpha beta: (double) beta;
+ (Mat)_flip:(Mat)source horizontal: (BOOL)horizontal vertical: (BOOL) vertical;
+ (Mat)_rotate:(Mat)source;

#endif

@end

@implementation OpenCVWrapper

 Mat result;
 Mat kernel = cv::getGaussianKernel(45, 0);

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    //uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    u_int8_t *baseAddress = (u_int8_t *)malloc(bytesPerRow * height);
    memcpy(baseAddress, CVPixelBufferGetBaseAddress(imageBuffer), bytesPerRow * height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow , colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *finalImage = [UIImage imageWithCGImage: newImage];
    
    free(baseAddress);
    CGImageRelease(newImage);
    
    return finalImage;
}

+ (cv::Mat)_matFrom:(UIImage *)source
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(source.CGImage);
    CGFloat cols = source.size.width;
    CGFloat rows = source.size.height;

    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), source.CGImage);
    CGContextRelease(contextRef);

    return cvMat;
}
+ (UIImage *)_imageFrom:(cv::Mat)source
{
    NSData *data = [NSData dataWithBytes:source.data length: source.elemSize()*source.total()];
    CGColorSpaceRef colorSpace;

    if (source.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(source.cols,                                 //width
                                        source.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * source.elemSize(),                       //bits per pixel
                                        source.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );


    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return finalImage;
}

+ (UIImage *)toGray:(UIImage *)source {
    return [OpenCVWrapper _imageFrom: [OpenCVWrapper _grayFrom: [OpenCVWrapper _matFrom: source]]];
}

+ (UIImage *)gaussianBlur:(UIImage *)source {
    return [OpenCVWrapper _imageFrom: [OpenCVWrapper _gaussianFrom: [OpenCVWrapper _matFrom: source]]];
}
+ (UIImage *)canny:(UIImage *)source {
    return [OpenCVWrapper _imageFrom: [OpenCVWrapper _cannyFrom: [OpenCVWrapper _matFrom: source]]];
}
+ (UIImage *)sobel:(UIImage *)source {
    return [OpenCVWrapper _imageFrom: [OpenCVWrapper _sobelFrom: [OpenCVWrapper _matFrom: source]]];
}
+ (UIImage *)brightness:(UIImage *)source beta: (double)beta {
    return [OpenCVWrapper _imageFrom: [OpenCVWrapper _adjustFrom: [OpenCVWrapper _matFrom: source] alpha:1 beta:beta]];
}
+ (UIImage *)contrast:(UIImage *)source alpha: (double)alpha {
    return [OpenCVWrapper _imageFrom: [OpenCVWrapper _adjustFrom: [OpenCVWrapper _matFrom: source] alpha: alpha beta: 0]];
}
+ (UIImage *)negative:(UIImage *)source {
    return [OpenCVWrapper _imageFrom: [OpenCVWrapper _adjustFrom: [OpenCVWrapper _matFrom: source] alpha: -1 beta: 255]];
}
+ (UIImage *)flipHorizontal:(UIImage *)source {
    return [OpenCVWrapper _imageFrom: [OpenCVWrapper _flip: [OpenCVWrapper _matFrom:source] horizontal: true vertical: false]];
}
+ (UIImage *)flipVertical:(UIImage *)source {
    return [OpenCVWrapper _imageFrom: [OpenCVWrapper _flip: [OpenCVWrapper _matFrom:source] horizontal: false vertical: true]];
}
+ (UIImage *)rotate:(UIImage *)source {
    return [OpenCVWrapper _imageFrom: [OpenCVWrapper _rotate: [OpenCVWrapper _matFrom:source]]];
}

+ (Mat)_grayFrom:(Mat)source {
   

    //Mat result;
    cvtColor(source, result, COLOR_BGR2GRAY);

    return result;
    
}

+ (Mat)_gaussianFrom:(Mat)source {
    
    
    //Mat result;
    //kernel = cv::getGaussianKernel(45, 0);
    cv::filter2D(source, result, -1, kernel);
    //cv::GaussianBlur(source, result, cv::Size(45,45), 0);
   // source.release();
    
    
    return result;
}

+ (Mat)_sobelFrom:(Mat)source {
    
    cv::Sobel(source, result, CV_16S, 1, 0);

    return result;
}

+ (Mat)_cannyFrom:(Mat)source {
    
    cv::Canny(source, result, 50, 150);
    
    return result;
}
+ (Mat)_adjustFrom:(Mat)source alpha: (double)alpha beta: (double) beta {
    
    source.convertTo( result, -1, alpha, beta);
    
    return result;
}
+ (Mat)_flip:(Mat)source horizontal: (BOOL)horizontal vertical: (BOOL) vertical {
    
    if (horizontal && vertical)  {
        cv::flip(source, result, -1);
    } else if (horizontal) {
        cv::flip(source, result, 1);
    } else if (vertical) {
        cv::flip(source, result, 0);
    }
    return result;
}
+ (Mat)_rotate:(Mat)source {
    
    cv::rotate(source, result, ROTATE_90_CLOCKWISE);
    return result;
}

@end
