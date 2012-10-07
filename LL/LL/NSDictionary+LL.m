//
//  NSDictionary+LLUtil.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "NSDictionary+LL.h"

@implementation NSDictionary (LL)

- (BOOL) empty { return self.count == 0; }
- (BOOL) unempty { return !self.empty; }
- (NSUInteger) length { return self.count; }
- (NSUInteger) size { return self.count; }

- (BOOL) hasKey:(id)key { return [self objectForKey:key] != nil; }
- (BOOL) containsKey:(id)key { return [self hasKey:key]; }

@end
