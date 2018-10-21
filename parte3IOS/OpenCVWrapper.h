//
//  OpenCVWrapper.h
//  parte3IOS
//
//  Created by Laura Corssac on 16/10/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface OpenCVWrapper : NSObject

+ (NSString *)openCVVersionString;
+ (UIImage *)toGray:(UIImage *)source;
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
+ (UIImage *)gaussianBlur:(UIImage *)source;
+ (UIImage *)sobel:(UIImage *)source;
+ (UIImage *)canny:(UIImage *)source;
+ (UIImage *)brightness:(UIImage *)source beta: (double)beta;
+ (UIImage *)contrast:(UIImage *)source alpha: (double)alpha;
+ (UIImage *)negative:(UIImage *)source;
+ (UIImage *)flipVertical:(UIImage *)source;
+ (UIImage *)flipHorizontal:(UIImage *)source;
+ (UIImage *)rotate:(UIImage *)source;

@end
