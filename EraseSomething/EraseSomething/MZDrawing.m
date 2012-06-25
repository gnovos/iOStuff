//
//  MZDrawing.m
//  EraseSomething
//
//  Created by Mason on 6/25/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZDrawing.h"

@implementation MZDrawing {
    NSMutableArray* strokes;
}

- (id) init {
    if (self = [super init]) {
        strokes = [NSMutableArray array];
    }
    return self;
}

@end
