//
//  KWEngine.m
//  KittenWrangler
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
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setValue:[NSNumber numberWithFloat:elapsed] forKey:kCATransactionAnimationDuration];
    [level tick:elapsed];
    [CATransaction commit];
        
    last = link.timestamp;
    
    if (level.complete) {
        level = [[KWLevel alloc] initLevel:level.level + 1];
        [callblocks enumerateObjectsUsingBlock:^(void(^block)(void), NSUInteger idx, BOOL *stop) {
            block();
        }];
    }
    
        
}

- (void) add:(void(^)(void))block {
    [callblocks addObject:[block copy]];
}


@end
