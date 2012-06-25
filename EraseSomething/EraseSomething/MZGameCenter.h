//
//  MZGameCenter.h
//  EraseSomething
//
//  Created by Mason on 6/24/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface MZGameCenter : NSObject <GKSessionDelegate>

+ (void) authenticate;

@end
