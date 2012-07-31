//
//  KWGameKit.h
//  Catpcha
//
//  Created by Mason on 7/30/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface KWGameManager : NSObject

+ (id) instance;

- (void) authenticate:(void(^)(void))success failure:(void(^)(void))failure;

@end
