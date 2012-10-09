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
    self.data = [NSMutableDictionary dictionary];
    self.views = [NSMutableDictionary dictionary];
    
    NSDictionary* data = [spec objectForKey:@"data"];
    
    NSDictionary* current = self.data;
    
    [data walk:^(NSString* key, id value) {
        NSLog(@"\napp key: %@\napp val: %@\n\n", key, value);
        [self.data setValue:value forPath:key];
    }];
    
    NSDictionary* views = [spec objectForKey:@"views"];
    NSLog(@"FINAL:\n\njson:\n%@\n\nlive:\n%@", data, self.data);
    [views walk:^(NSString* key, id value) {
        NSLog(@"\nview key: %@\nview val: %@\n\n", key, value);
        [self.views setValue:value forPath:key];
    } withData:self.data];
    NSLog(@"VIEWS:\n\njson:\n%@\n\nlive:\n%@", views, self.views);
    
}

@end
