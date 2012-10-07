//
//  NSMutableDictionary+LL.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "NSMutableDictionary+LL.h"

@implementation NSMutableDictionary (LL)

- (id) yankObjectForKey:(id)key {
    @synchronized(self) {
        id obj = [self objectForKey:key];
        [self removeObjectForKey:key];
        return obj;
    }
}


@end
