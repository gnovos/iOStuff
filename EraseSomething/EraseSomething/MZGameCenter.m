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
    NSLog(@"Authentication Changed");
    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
    } else {
        NSLog(@"Authentication changed: player not authenticated");
    }
    
}

/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    
}

/* Indicates a connection request was received from another peer. 
 
 Accept by calling -acceptConnectionFromPeer:
 Deny by calling -denyConnectionFromPeer:
 */
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    
}

/* Indicates a connection error occurred with a peer, which includes connection request failures, or disconnects due to timeouts.
 */
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    
}

/* Indicates an error occurred with the session such as failing to make available.
 */
- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    
}



@end
