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
    KWEngineEventTick,
    KWEngineEventLevelComplete,
    KWEngineEventLevelBegin
} KWEngineEvent;

@interface KWEngine : NSObject

@property (nonatomic, readonly, strong) KWLevel* level;

- (void) start;
- (void) stop;
- (void) pause;

- (void) attach:(id)target forEvent:(KWEngineEvent)event withHandler:(void(^)(id target, id data))handler;

@end
