//
//  KWGameKit.m
//  Catpcha
//
//  Created by Mason on 7/30/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWGameManager.h"

@interface KWGameManager ()

@property (nonatomic, strong) NSString* playerID;

@end

@implementation KWGameManager

@synthesize playerID;

+ (id) instance {
    static KWGameManager* manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ manager = [[KWGameManager alloc] init]; });
    return manager;
}

- (void) authenticate:(void(^)(void))success failure:(void(^)(void))failure {
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    if (gcClass && osVersionSupported) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            playerID = localPlayer.isAuthenticated ? localPlayer.playerID : nil;
            if (playerID) {
                success();
            } else {
                failure();
            }
        }];
    } else {
        failure();
    }
}

@end
