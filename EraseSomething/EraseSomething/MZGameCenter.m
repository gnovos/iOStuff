//
//  MZGameCenter.m
//  EraseSomething
//
//  Created by Mason on 6/24/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZGameCenter.h"

@implementation MZGameCenter

+ (void) authenticate {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
    });
    
    BOOL available = ((NSClassFromString(@"GKLocalPlayer")) && ([[[UIDevice currentDevice] systemVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending));
    
    if (available) {
        
        if ([GKLocalPlayer localPlayer].authenticated == NO) {                 
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError* error) {
                NSLog(@"error was: %@", error);
            }];
        } else {
            NSLog(@"Already authenticated!");
        }
        
    }
    
}

+ (void) authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
    } else {
        NSLog(@"Authentication changed: player not authenticated");
    }
    
}


@end
