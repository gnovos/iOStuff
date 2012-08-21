//
//  LLAppDelegate.m
//  CasuaLlama
//
//  Created by Mason on 8/18/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "LLAppDelegate.h"

@implementation LLAppDelegate

@synthesize settings;

+ (id) instance { return [[UIApplication sharedApplication] delegate]; }

- (NSURL*) documents { return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]; }
- (UINavigationController*) root { return (UINavigationController*)self.window.rootViewController; }
- (void) raise:(NSError*)error { [[NSException exceptionWithName:@"LLFatalException" reason:[error localizedDescription] userInfo:[error userInfo]] raise]; }

- (void) alert:(NSString*)action message:(NSString*)message {
    NSString* name = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleExecutableKey];
    [[[UIAlertView alloc] initWithTitle:name
                                message:message
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:action, nil] show];
}

- (void) application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)note {
    if ([application applicationState] == UIApplicationStateActive) {
        [self alert:note.alertAction message:note.alertBody];
    } else {
        [self handle:[note.alertAction lowercaseString] info:note.userInfo];
    }
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    UILocalNotification* note = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (note) { [self handle:[note.alertAction lowercaseString] info:note.userInfo]; }
    
    settings = [NSUserDefaults standardUserDefaults];
    [settings synchronize];
    
    [self notify];
    self.root.delegate = self;
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication*)application { }
- (void)applicationDidBecomeActive:(UIApplication*)application     { }
- (void)applicationWillResignActive:(UIApplication*)application    { }
- (void)applicationDidEnterBackground:(UIApplication*)application  { }
- (void)applicationWillTerminate:(UIApplication*)application       { }

- (void)alertView:(UIAlertView*)alert clickedButtonAtIndex:(NSInteger)index {
    if (index != alert.cancelButtonIndex) { [self handle:[[alert buttonTitleAtIndex:index] lowercaseString] info:nil]; }
}

- (void) handle:(NSString*)action info:(NSDictionary*)info {
    if ([@"call" isEqualToString:action]) {
        [self open:[NSURL URLWithString:[@"tel:" stringByAppendingString:[info objectForKey:@"number"]]]];
    } else if ([@"open" isEqualToString:action]) {
        [self open:[info objectForKey:@"url"]];
    }
}

- (void) open:(NSURL*)url {
    [[UIApplication sharedApplication] openURL:url];
}

- (void) notify {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];    
}

- (void)navigationController:(UINavigationController*)nav willShowViewController:(UIViewController*)vc animated:(BOOL)animated {
    BOOL root = [nav.viewControllers objectAtIndex:0] == vc;
    [nav setNavigationBarHidden:root animated:animated];
}

- (void)navigationController:(UINavigationController*)nav didShowViewController:(UIViewController*)vc animated:(BOOL)animated {
    BOOL root = [nav.viewControllers objectAtIndex:0] == vc;
    [nav setNavigationBarHidden:root animated:animated];
}


@end
