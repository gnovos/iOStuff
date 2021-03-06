//
//  KWEngine.h
//  Catpcha
//
//  Created by Mason Glaves on 7/16/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWLevel.h"

typedef enum {
    KWEngineEventMatchBegin,
    KWEngineEventTick,
    KWEngineEventLevelComplete,
    KWEngineEventLevelBegin
} KWEngineEvent;

@interface KWEngine : NSObject <GKMatchDelegate>

@property (nonatomic, readonly, strong) KWLevel* level;

+ (id) instance;

- (void) setMatch:(GKMatch*)gkmatch;

- (void) start:(BOOL)paused;
- (void) stop;
- (void) pause;
- (void) unpause;

- (void) attach:(id)target forEvent:(KWEngineEvent)event withHandler:(void(^)(id target, id data))handler;

- (void) authenticate:(void(^)(void))success failure:(void(^)(NSError* error))failure;
- (void) save;

@end
