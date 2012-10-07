//
//  LLApplicationBuilder.m
//  LL
//
//  Created by Mason on 10/5/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "LLApplicationBuilder.h"
#import "NSDictionary+LL.h"

@implementation LLApplicationBuilder

- (void) build:(NSDictionary*)spec {
    self.data = [NSMutableDictionary dictionary];
    NSDictionary* data = [spec objectForKey:@"data"];
    
    [data walk:^(NSString* key, id value) {
        if ([value isKindOfClass:NSString.class]) {
            
        }
    }];
    
}

- (void) interpolate:(NSDictionary*)dict {
    
}


@end
