//
//  KWViewController.m
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWGameViewController.h"
#import "KWRenderView.h"
#import <CoreMotion/CoreMotion.h>
#import "KWAlert.h"
#import "KWEngine.h"
#import "CALayer+KWMsg.h"

@interface KWGameViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) CMMotionManager *motion;
@property (nonatomic, weak) IBOutlet KWRenderView* render;

@end

@implementation KWGameViewController {
    KWEngine* engine;
}

@synthesize render, motion;

- (void) viewWillDisappear:(BOOL)animated {
    [engine pause];
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [engine unpause];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    engine = [[KWEngine alloc] init];
    render.level = engine.level;
        
    KWRenderView* renderer = self.render;
    
    [engine attach:self forEvent:KWEngineEventLevelComplete withHandler:^(UIViewController* game, KWLevel* level) {
        NSString* msg = level.solved ? @"Way to go, you failed to fail!" : @"Wow, you suck...";
        [self.view.layer hover:msg over:self.view.center];
    }];
    
    [engine attach:renderer forEvent:KWEngineEventLevelBegin withHandler:^(KWRenderView* rend, KWLevel* level) {
        rend.level = level;
    }];
    
    [engine attach:renderer forEvent:KWEngineEventTick withHandler:^(KWRenderView* rend, NSNumber* dt) {
        [rend tick:[dt floatValue]];
    }];
    
    motion = [[CMMotionManager alloc] init];
    
//xxx figure this out later
//    if (motion.isDeviceMotionAvailable) {
//		motion.deviceMotionUpdateInterval = 1.0f / 4.0f;
//        [motion startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion* move, NSError* error) {
//            if (ABS(move.userAcceleration.x) > 0.5 || ABS(move.userAcceleration.y) > 0.5) {
//                [renderer addVelocity:CGPointMake(move.userAcceleration.x, move.userAcceleration.y)];
//            }
//            
//            CMAttitude* attitude = move.attitude;
//            engine.level.bias = CGPointMake(attitude.roll, attitude.pitch);
//         }];
//    }
    
    [engine start:YES];
    
}

@end
