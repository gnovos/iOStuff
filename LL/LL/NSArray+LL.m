//
//  NSArray+LL.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "NSArray+LL.h"

@implementation NSArray (LL)

- (BOOL) empty { return self.count == 0; }
- (BOOL) unempty { return !self.empty; }
- (NSUInteger) length { return self.count; }
- (NSUInteger) size { return self.count; }

- (id) firstObject { return self.count == 0 ? nil : [self objectAtIndex:0]; }

@end
