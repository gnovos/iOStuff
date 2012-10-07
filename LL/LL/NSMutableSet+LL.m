//
//  NSMutableSet+LL.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "NSMutableSet+LL.h"

@implementation NSMutableSet (LL)

- (BOOL) removeIfContained:(id)obj {
    @synchronized(self) {
        BOOL contained = [self containsObject:obj];
        if (contained) {
            [self removeObject:obj];
        }
        return contained;
    }
}


@end
