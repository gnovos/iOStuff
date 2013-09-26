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

- (void) build:(NSString*)resource {
    self.data = [NSMutableDictionary dictionary];
    self.views = [NSMutableDictionary dictionary];

    NSURL* url = [[NSBundle mainBundle] URLForResource:resource withExtension:@"json"];
    NSDictionary* spec = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url]
                                                         options:NSJSONReadingMutableContainers
                                                           error:NULL];
    
    [[spec objectForKey:@"data"] walk:^(NSString* key, id value) {
        [self.data setValue:value forPath:key];
    }];
    
    [[spec objectForKey:@"views"] walk:^(NSString* key, id value) {
        [self.views setValue:value forPath:key];
    } referencing:self.data];
}

- (LLViewController*) create:(NSString*)name {
    UIStoryboard* storyboard = nil;
    
    NSDictionary* view = [self.views valueForPath:name];
    
    NSString* viewname = [view valueForPath:@"template"];
    if (viewname != nil) {
        viewname = name;
    }
    
    LLViewController* vc = [storyboard instantiateViewControllerWithIdentifier:viewname];
    
    //xxx set objects
    
    return vc;
}

@end
