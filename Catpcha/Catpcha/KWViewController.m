//
//  KWViewController.m
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWViewController.h"
#import "KWRenderView.h"
#import <CoreMotion/CoreMotion.h>
#import "KWGameManager.h"

@interface KWViewController ()

@property (nonatomic, strong) CMMotionManager *motion;

@end

@implementation KWViewController {
    IBOutlet KWRenderView* render;
}

@synthesize motion;

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[KWGameManager instance] authenticate:^{
        [render start];
    } failure:^{
        [[[UIAlertView alloc] initWithTitle:@"Oh Meow!"
                                    message:@"We couldn't authenticate with Game Genter.  :(  Without authenticating with game center you'll find gameplay kinda limited."
                                   delegate:nil
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil] show];
        [render start];
    }];

}

- (void) viewWillDisappear:(BOOL)animated {
    [render pause];
    [super viewWillDisappear:animated];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    motion = [[CMMotionManager alloc] init];
    
    if (motion.isDeviceMotionAvailable) {
		motion.deviceMotionUpdateInterval = 1.0 / 30.0;
        [motion startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion* move, NSError* error) {
            NSLog(@"moved: %@", move);
//xxx
//             CATransform3D transform;
//             transform = CATransform3DMakeRotation(move.attitude.pitch, 1, 0, 0);
//             transform = CATransform3DRotate(transform, move.attitude.roll, 0, 1, 0);
//             
//             self.view.layer.sublayerTransform = transform;
         }];
    }
}

@end
