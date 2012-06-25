//
//  MZGameCenter.m
//  FlipOut
//
//  Created by Mason on 6/13/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZGameCenter.h"
#import <GameKit/GameKit.h>

@implementation MZGameCenter

+ (BOOL) isGameCenterAvailable {
    
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

+ (void) authenticateLocalUser {
    
    if (![self isGameCenterAvailable]) {
        [[[UIAlertView alloc] initWithTitle:@"Doh!"
                                   message:@"Unfortunately the game center is required to use this fantastic thing."
                                  delegate:nil
                         cancelButtonTitle:@"Okay...  :("
                         otherButtonTitles:nil] show];        
    } else {
        GKLocalPlayer* player = [GKLocalPlayer localPlayer];
        if (player.authenticated == NO) {        
            [player authenticateWithCompletionHandler:^(NSError *error) {
                NSLog(@"error is: %@", error);
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:@"Unfortunately you need to log into the game center for this to work.  :("
                                           delegate:nil
                                  cancelButtonTitle:@"Try again, maybe?"
                                  otherButtonTitles:nil] show];
            }];
        }
        
    }
     
}




@end
