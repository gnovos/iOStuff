//
//  MZInvoker.m
//  MZCore
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MZInvoker.h"

@implementation MZInvoker

- (id) initWithTarget:(id)target {
    return [self initWithTarget:target andThread:nil];
}

- (id) initWithTarget:(id)target andThread:(NSThread *)context {
    parent = target;
    thread = context;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [parent methodSignatureForSelector:selector];
}

- (void) forwardInvocation:(NSInvocation *)nvoc {
    [nvoc setTarget:parent];
    if (thread != nil) {
        [nvoc performSelector:@selector(invoke) onThread:thread withObject:nil waitUntilDone:YES];        
    } else {
        [nvoc invoke];
    }
}


@end
