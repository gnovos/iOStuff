//
//  NSObject+LL.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "NSObject+LL.h"
#import "NSString+LL.h"

@implementation NSObject (LL)

- (NSString*) str { return [self respondsToSelector:@selector(stringValue)] ? [self performSelector:@selector(stringValue)] : [self description]; }

- (void) listenFor:(NSString*)notification andInvoke:(void(^)(NSNotification *note))nvok { [[NSNotificationCenter defaultCenter] addObserverForName:notification object:nil queue:nil usingBlock:nvok]; }
- (void) listenFor:(NSString*)notification andPerform:(SEL)selector { [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:notification object:nil]; }
- (void) stopListeningFor:(NSString*)notification { [[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:nil]; }
- (void) stopListeningForNotifications { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void) postNotice:(NSString*)notification { [self postNotice:notification withObject:nil]; }
- (void) postNotice:(NSString*)notification withObject:(id)object { [[NSNotificationCenter defaultCenter] postNotificationName:notification object:object]; }

- (id) expand:(id)value {
    static NSRegularExpression* expander;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        expander = [NSRegularExpression regularExpressionWithPattern:@"^#\\{(.*)\\}$" options:0 error:NULL];
    });
    
    NSString* path = nil;
    if ((path = [[value str] match:expander]) != nil) {
        value = [self valueForPath:path root:self];
    }
    return value;
}

- (id) valueForPath:(NSString*)path {
    return [self valueForPath:path root:self];
}

- (id) valueForPath:(NSString*)path root:(id)root {
    NSArray* split = [path split:@".["];
    __block id value = self;
    [split enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
        key = [key trim:@"[]"];
        if ([value isKindOfClass:NSArray.class]) {
            NSInteger index = [key intValue];
            value = [value objectAtIndex:index];
        } else if ([value isKindOfClass:NSDictionary.class]) {
            value = [value valueForKey:key];
        } else {
            value = [root expand:value];
        }
    }];
    
    return [root expand:value];
}

- (void) setValue:(id)value forPath:(NSString*)path {
    [self setValue:value forPath:path root:self];
}

- (void) setValue:(id)value forPath:(NSString*)path root:(id)root {
    NSArray* split = [path split:@".["];
    
    NSString* key = nil;
    id current = self;
    for (int i = 0; i < split.count - 1; i++) {
        key = [[split objectAtIndex:i] trim:@"[]"];
        
        if ([current isKindOfClass:NSMutableArray.class]) {
            NSInteger index = [key intValue];
            if (index >= [current count]) {
                int missing = (1 + index - [current count]);
                for (int fill = 0; fill < missing; fill++){
                    [current addObject:[NSNull null]];
                }
            }
            
            id next = [current objectAtIndex:index];
            if ([next isEqual:[NSNull null]]) {
                NSString* nextKey = [split objectAtIndex:i + 1];
                if ([nextKey hasSuffix:@"]"]) {
                    next = [NSMutableArray array];
                    [current setObject:next atIndex:index];
                } else {
                    next = [NSMutableDictionary dictionary];
                    [current setObject:next atIndex:index];
                }                
            }
            current = next;
        } else if ([current isKindOfClass:NSMutableDictionary.class]) {
            id next = [current valueForKey:key];
            if (next == nil) {
                NSString* nextKey = [split objectAtIndex:i + 1];
                if ([nextKey hasSuffix:@"]"]) {
                    next = [NSMutableArray array];
                    [current setObject:next forKey:key];
                } else {
                    next = [NSMutableDictionary dictionary];
                    [current setObject:next forKey:key];
                }                
            }
            current = next;
        }
    }
    
    key = [split.lastObject trim:@"[]"];
    if ([current isKindOfClass:NSMutableArray.class]) {
        NSInteger index = [key intValue];
        [current setObject:[root expand:value] atIndex:index];
    } else if ([current isKindOfClass:NSMutableDictionary.class]) {
        [current setValue:[root expand:value] forKey:key];
    }
    
}

- (void) walk:(void(^)(NSString* key, id value))block {
    [self walk:block withPrefix:nil root:self];
}

- (void) walk:(void(^)(NSString* key, id value))block withPrefix:(NSString*)prefix root:(id)root {
    
    if ([self isKindOfClass:NSDictionary.class]) {
        [((NSDictionary*)self) enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
            key = prefix ? [prefix stringByAppendingFormat:@".%@", key] : key;
            if ([value isKindOfClass:NSDictionary.class] || [value isKindOfClass:NSArray.class]) {
                [value walk:block withPrefix:key root:self];
            } else {
                block(key, [root expand:value]);
            }
        }];
    } else if ([self isKindOfClass:NSArray.class]) {
        [((NSArray*)self) enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
            NSString* key = prefix ? [prefix stringByAppendingFormat:@"[%d]", idx] : ns(@"[%d]", idx);
            if ([value isKindOfClass:NSDictionary.class] || [value isKindOfClass:NSArray.class]) {
                [value walk:block withPrefix:key root:root];
            } else {
                block(key, [root expand:value]);
            }            
        }];
    } else {
        block(@"", self);
    }
    
}


@end
