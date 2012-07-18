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
}

@synthesize level;

- (id) init {
    if (self = [super init]) {
        level = [[KWLevel alloc] initLevel:1];
    }
    return self;    
}

- (void) start {
    [self stop];
    loop = [CADisplayLink displayLinkWithTarget:self selector:@selector(loop:)];
    
    //loop.frameInterval = 10; //xxx slooow it down for testing
    
    [loop addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) stop {
    [loop invalidate];
    loop = nil;
}

- (void) pause { loop.paused = YES; }
 
- (void) loop:(CADisplayLink*)link {
    
    CFTimeInterval elapsed = link.timestamp - last;
    
    [level tick:elapsed];
        
    last = link.timestamp;
    
    if (level.complete) {
        level = [[KWLevel alloc] initLevel:level.level + 1];
    }
        
}


@end
