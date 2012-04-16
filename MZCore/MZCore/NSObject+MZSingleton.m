//
//  NSObject+MZSingleton.m
//  MZCore
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "NSObject+MZSingleton.h"

#import "MZInvoker.h"

#define kMZNotFound -1

#define kMZSingletonBufferIncrement 64

@implementation NSObject (MZSingleton)

+ (id) singleton {
    
    static NSLock* _mutex;
    
    static int _count = 0;    
    static void** _singletons;    
    static Class* _classes;
    static dispatch_once_t* _tokens;
    
    static int _size  = kMZSingletonBufferIncrement;
    static dispatch_once_t init = 0;       
    dispatch_once(&init, ^{ 
        _mutex      = [[NSLock alloc] init];        
        _singletons = (void**)           calloc(_size, sizeof(void*)); 
        _classes    = (Class*)           calloc(_size, sizeof(Class));
        _tokens     = (dispatch_once_t*) calloc(_size, sizeof(dispatch_once_t));        
    });
    
    int location = kMZNotFound;
    
    Class singletonClass = [self class];
    
    for (int i = 0; i < _count; i++) {
        if (_classes[i] == singletonClass) {
            location = i;
            break;
        }        
    }
    
    if (location == kMZNotFound) {
        
        [_mutex lock];
        
        for (int i = 0; i < _count; i++) {
            if (_classes[i] == singletonClass) {
                location = i;
                break;
            }        
        }
        
        if (location == kMZNotFound) {
            
            if (_count == _size) {
                _size      += kMZSingletonBufferIncrement;        
                _singletons = (void**)           realloc(_singletons, _size * sizeof(void*)); 
                _classes    = (Class*)           realloc(_classes,    _size * sizeof(Class));        
                _tokens     = (dispatch_once_t*) realloc(_tokens,     _size * sizeof(dispatch_once_t));        
            }
            
            location = _count;            
            _classes[location] = singletonClass;
            _count++;
        }
        
        [_mutex unlock];
        
    }
    
    dispatch_once_t* token = &_tokens[location];
    
    dispatch_once(token, ^{  
        id wrapped;
        
        id allocated = [self alloc];
        
        if ([allocated respondsToSelector:@selector(initSingleton)]) {
            wrapped = [allocated initSingleton];
        } else {
            wrapped = [allocated init];             
        }
        
        MZInvoker* singleton = [[MZInvoker alloc] initWithTarget:wrapped];
        
        _singletons[location] = (__bridge_retained void*)singleton;
    });
    
    
    return (__bridge id) _singletons[location];
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    if ([self conformsToProtocol:@protocol(MZSingleton)]) {
        return [[self singleton] methodSignatureForSelector:selector];        
    }
    return [self methodSignatureForSelector:selector];
}

+ (void) forwardInvocation:(NSInvocation *)nvoc {
    if ([self conformsToProtocol:@protocol(MZSingleton)]) {
        [nvoc setTarget:[self singleton]];
        [nvoc invoke];
    } else {
        [self forwardInvocation:nvoc];
    }    
}


@end
