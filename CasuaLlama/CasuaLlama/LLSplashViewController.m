//
//  LLSplashViewController.m
//  CasuaLlama
//
//  Created by Mason on 9/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "LLSplashViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LLSplashViewController ()
@end

@implementation LLSplashViewController

- (void) configure {
    self.app.application.statusBarHidden = YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.app.library update:^{
        [self fade:@"editions" duration:1.4f];
    }];
    
}

@end
