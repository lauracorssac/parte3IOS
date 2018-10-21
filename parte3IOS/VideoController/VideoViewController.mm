//
//  VideoViewController.m
//  parte3IOS
//
//  Created by Laura Corssac on 17/10/2018.
//  Copyright © 2018 Laura Corssac. All rights reserved.
//

#import "VideoViewController.h"


@interface VideoViewController ()

@end


@implementation VideoViewController

@synthesize videoCamera;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    printf("loaded");
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView: imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
}

- (IBAction)startPressed:(UIButton *)sender {
    [self.videoCamera start];
}



@end
