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
#import "KWAlert.h"
#import "KWEngine.h"

@interface KWViewController ()

@property (nonatomic, strong) CMMotionManager *motion;
@property (nonatomic, weak) IBOutlet KWRenderView* render;

@end

@implementation KWViewController {
    KWEngine* engine;
}

@synthesize render, motion;

- (void) login {
    //xxx check if already authenticated?
    [[KWGameManager instance] authenticate:^{
        [self start];
    } failure:^{
        [KWAlert alert:@"Oh Meow!"
               message:@"We couldn't authenticate with Game Genter.  :(  Without authenticating with game center you'll find gameplay kinda limited."
               actions:@{ @"Okay": ^{ [self start]; }, @"Try Again" : ^{ [self login]; } }];
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self login];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self pause];
    [super viewWillDisappear:animated];
}

- (void) start { [engine start]; }

- (void) stop { [engine stop]; }

- (void) pause { [engine pause]; }

- (void) viewDidLoad {
    [super viewDidLoad];
    
    engine = [[KWEngine alloc] init];
    render.level = engine.level;
    
    KWRenderView* renderer = self.render;
    [engine add:^(KWEngineEvent event, id level) {
        if (event == KWEngineEventLevelBegin) {
            renderer.level = level;            
        }
    }];

    motion = [[CMMotionManager alloc] init];
    
    if (motion.isDeviceMotionAvailable) {
		motion.deviceMotionUpdateInterval = 1.0f / 4.0f;
        [motion startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion* move, NSError* error) {
            CMAttitude* attitude = move.attitude;
            engine.level.bias = CGPointMake(attitude.roll, attitude.pitch);
         }];
    }
}

@end
