//
//  VideoViewController.h
//  parte3IOS
//
//  Created by Laura Corssac on 17/10/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>

using namespace cv;

@interface VideoViewController : UIViewController
{
    IBOutlet UIImageView *imageView;
    CvVideoCamera* videoCamera;
    
}
@property (nonatomic, retain) CvVideoCamera* videoCamera;
@end
