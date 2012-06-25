//
//  MZStroke.m
//  EraseSomething
//
//  Created by Mason on 6/25/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZStroke.h"

@implementation MZStroke

@synthesize start, end;

- (id) initWithStart:(CGPoint)startPoint {
    if (self = [super init]) { start = startPoint; }
    return self;
}

@end
