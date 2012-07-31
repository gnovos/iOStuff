//
//  KWViewController.m
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWViewController.h"
#import "KWRenderView.h"

@interface KWViewController ()

@end

@implementation KWViewController {
    IBOutlet KWRenderView* render;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [render start];
}

- (void) viewWillDisappear:(BOOL)animated {
    [render pause];
    [super viewWillDisappear:animated];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / 30.0];
    [UIAccelerometer sharedAccelerometer].delegate = self;
}

- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
    NSLog(@"x:%f y:%f z:%f", acceleration.x, acceleration.y, acceleration.z);
}

@end
