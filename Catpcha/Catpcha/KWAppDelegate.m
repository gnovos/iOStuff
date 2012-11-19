//
//  KWAppDelegate.m
//  Catpcha
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWAppDelegate.h"
#import "KWEngine.h"
#import "KWAnalytics.h"

#import "NSString+KWColor.h"

@implementation KWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [KWAnalytics init];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication*)application    { [KWEngine.instance pause]; }
- (void)applicationDidEnterBackground:(UIApplication*)application  { [KWEngine.instance pause]; }
- (void)applicationWillEnterForeground:(UIApplication*)application { [KWEngine.instance unpause]; }
- (void)applicationDidBecomeActive:(UIApplication*)application     { [KWEngine.instance unpause]; }
- (void)applicationWillTerminate:(UIApplication *)application      { [KWEngine.instance stop]; }

@end
