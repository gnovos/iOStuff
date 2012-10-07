//
//  NSDictionary+LLUtil.h
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (LL)

- (void) walk:(void(^)(id key, id value))block;

@end
