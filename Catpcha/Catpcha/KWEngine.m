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
    CFTimeInterval last;
    NSMutableArray* callblocks;
    
    CGPoint bias;
}

@synthesize level;

- (id) init {
    if (self = [super init]) {
        level = [[KWLevel alloc] initLevel:1];
        callblocks = [[NSMutableArray alloc] init];
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
    
    CFTimeInterval elapsed = link.timestamp - last;
    
    [KWGFX animate:elapsed animation:^{
        [level tick:elapsed];
    } onComplete:nil];
            
    last = link.timestamp;
    
    if (level.complete) {
        level = [[KWLevel alloc] initLevel:level.level + 1];
        [callblocks enumerateObjectsUsingBlock:^(void(^block)(KWEngineEvent event, id object), NSUInteger idx, BOOL *stop) {
            block(KWEngineEventLevelComplete, level);
        }];
    }
}

- (void) add:(void(^)(KWEngineEvent event, id obj))block {
    [callblocks addObject:[block copy]];
}

- (void) bias:(CGPoint)attitude {
    bias = attitude;
}


@end
