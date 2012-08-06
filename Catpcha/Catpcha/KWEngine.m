//
//  KWEngine.m
//  Catpcha
//
//  Created by Mason Glaves on 7/16/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWEngine.h"
#import "KWBasket.h"
#import "KWKitten.h"
#import "KWLevel.h"

@implementation KWEngine {        
    CADisplayLink* loop;
    NSTimeInterval last;
    NSMutableDictionary* handlers;
}

@synthesize level;

- (id) init {
    if (self = [super init]) {
        level = [[KWLevel alloc] initLevel:1];
        handlers = [[NSMutableDictionary alloc] init];
    }
    return self;    
}

- (void) start {
    [self stop];
    loop = [CADisplayLink displayLinkWithTarget:self selector:@selector(loop:)];
        
    [loop addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) stop {
    [loop invalidate];
    loop = nil;
}

- (void) pause { loop.paused = YES; }
 
- (void) loop:(CADisplayLink*)link {
    
    NSTimeInterval elapsed = link.timestamp - last;
    
    [KWGFX animate:elapsed animation:^{
        [level tick:elapsed];
        [[handlers objectForKey:@(KWEngineEventTick)] enumerateObjectsUsingBlock:^(void(^handler)(id dt), NSUInteger idx, BOOL *stop) {
            handler(@(elapsed));
        }];
    } onComplete:nil];
            
    last = link.timestamp;
    
    if (level.complete) {
        [[handlers objectForKey:@(KWEngineEventLevelComplete)] enumerateObjectsUsingBlock:^(void(^handler)(id level), NSUInteger idx, BOOL *stop) {
            handler(level);
        }];
        
        level = [[KWLevel alloc] initLevel:level.level + 1];
        
        [[handlers objectForKey:@(KWEngineEventLevelBegin)] enumerateObjectsUsingBlock:^(void(^handler)(id level), NSUInteger idx, BOOL *stop) {
            handler(level);
        }];
    }
}

- (void) attach:(id)target forEvent:(KWEngineEvent)event withHandler:(void(^)(id target, id data))handler {
    __weak id t = target;
    NSMutableArray* h = [handlers objectForKey:@(event)];
    if (h == nil) {
        h = [[NSMutableArray alloc] init];
        [handlers setObject:h forKey:@(event)];
    }
    [h addObject:[^(id data){ handler(t, data); } copy]];
}

@end
