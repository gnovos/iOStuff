//
//  KWAppDelegate.m
//  Catpcha
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWAppDelegate.h"
#import "KWApplication.h"
#import "KWEngine.h"

@implementation KWAppDelegate

@synthesize window = _window;

- (void) checkpoint:(NSString*)checkpoint {
    @try {
        [TestFlight passCheckpoint:checkpoint];
    }
    @catch (id exception) {
        elog(exception);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    @try {
        [TestFlight takeOff:@"4458812bd5ebcfc812a03b2015057c83_MTAzMTA2MjAxMi0wNi0yMyAwMTo1Nzo0OS40NzgyMDg"];
        [TestFlight setDeviceIdentifier:[KWApplication deviceID]];
        [self checkpoint:KWCheckpointLaunch];
    }
    @catch (id exception) {
        elog(exception);
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication*)application    { [KWEngine.instance pause]; }
- (void)applicationDidEnterBackground:(UIApplication*)application  { [KWEngine.instance pause]; }
- (void)applicationWillEnterForeground:(UIApplication*)application { [KWEngine.instance unpause]; }
- (void)applicationDidBecomeActive:(UIApplication*)application     { [KWEngine.instance unpause]; }
- (void)applicationWillTerminate:(UIApplication *)application      { [KWEngine.instance stop]; }

- (IBAction) launchFeedback { [TestFlight openFeedbackView]; }

@end
