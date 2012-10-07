//
//  NSDictionary+LLUtil.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "NSDictionary+LL.h"

@implementation NSDictionary (LL)

- (void) walk:(void(^)(id key, id value))block {
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        block(key, value);
        if ([value isKindOfClass:[NSDictionary class]]) {
            [value walk:block];
        }
    }];
    
}

@end
