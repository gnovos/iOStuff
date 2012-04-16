//
//  NSObject+MZThreading.m
//  MZCore
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "NSObject+MZThreading.h"
#import "MZInvoker.h"

@implementation NSObject (MZThreading)

- (id) main {    
    return [[MZInvoker alloc] initWithTarget:self andThread:[NSThread mainThread]];
}

- (id) thread:(NSThread*)thread {
    return [[MZInvoker alloc] initWithTarget:self andThread:thread];    
}


@end
