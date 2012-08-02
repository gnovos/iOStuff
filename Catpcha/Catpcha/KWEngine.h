//
//  KWEngine.h
//  Catpcha
//
//  Created by Mason Glaves on 7/16/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWLevel.h"

typedef enum {
    KWEngineEventLevelComplete
} KWEngineEvent;

@interface KWEngine : NSObject

@property (nonatomic, readonly, strong) KWLevel* level;

- (void) start;
- (void) stop;
- (void) pause;

- (void) add:(void(^)(KWEngineEvent event, id obj))block;

@end
