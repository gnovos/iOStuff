//
//  LLApplicationBuilder.m
//  LL
//
//  Created by Mason on 10/5/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "LLApplicationBuilder.h"
#import "NSObject+LL.h"
#import "NSString+LL.h"

@implementation LLApplicationBuilder

- (void) build:(NSDictionary*)spec {
    static NSRegularExpression* matcher;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        matcher = [NSRegularExpression regularExpressionWithPattern:@"^#\\{(.*)\\}$" options:0 error:NULL];
    });
    
    self.data = [NSMutableDictionary dictionary];
    
    NSDictionary* data = [spec objectForKey:@"data"];
    
    NSDictionary* current = self.data;
    
    [data walk:^(NSString* key, id value) {
        if ([value isKindOfClass:NSString.class]) {
            NSString* path = [value match:matcher];
            if (path) {
                //lookup
            } else {
                [current setValue:value forKey:key];
            }
        }
    }];
    
}

@end
