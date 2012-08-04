//
//  NSObject+KWO.m
//  Catpcha
//
//  Created by Mason on 8/3/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "NSObject+KW.h"
#import <objc/runtime.h>

static void* ASSOC_KEY;

@interface KWObserver : NSObject

@property (nonatomic, assign) id parent;

- (id) initWithParent:(id)parent forKeyPath:(NSString*)keyPath withBlock:(void(^)(NSDictionary* change))block;

@end

@implementation KWObserver {
    NSString* path;
    void(^observer)(NSDictionary* change);
}

- (id) initWithParent:(id)rents forKeyPath:(NSString*)keyPath withBlock:(void(^)(NSDictionary* change))block {
    if (self = [self init]) {
        self.parent = rents;
        observer = [block copy];
        path = keyPath;
    }
    return self;
}
- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if (observer) { observer(change); }
}

- (void) dealloc {
    [self.parent removeObserver:self forKeyPath:path];
    observer = nil;
    self.parent = nil;
}

@end

@implementation NSObject (KWO)

- (void) observe:(NSString*)keyPath with:(void(^)(NSDictionary* change))block {
    NSMutableSet* observers = objc_getAssociatedObject(self, &ASSOC_KEY);
    if (observers == nil) {
        observers = [[NSMutableSet alloc] init];
        objc_setAssociatedObject(self, &ASSOC_KEY, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    KWObserver* obz = [[KWObserver alloc] initWithParent:self forKeyPath:keyPath withBlock:block];
    [self addObserver:obz forKeyPath:keyPath options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
    
    [observers addObject:obz];
}

- (NSValue*) ptr { return [NSValue valueWithPointer:(__bridge const void *)self]; }

@end
