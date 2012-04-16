//
//  NSObject+Debug.m
//  MZCore
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "NSObject+MZDebug.h"
#import "NSObject+MZProperties.h"
#import "NSString+MZRegexp.h"
#import <execinfo.h>

#define kMZ_DEFAULT_BACKTRACE_DEPTH 128

@implementation NSObject (MZDebug)

+ (NSArray*) backtrace {
    return [self backtrace:kMZ_DEFAULT_BACKTRACE_DEPTH];    
}

+ (NSArray*) backtrace:(int)depth {
    
    void *addr[depth];
    int nframes = backtrace(addr, sizeof(addr)/sizeof(*addr));
    
    if (nframes > 0) {
        NSMutableArray* stack = [[NSMutableArray alloc] initWithCapacity:nframes];
        
        char **syms = backtrace_symbols(addr, nframes);
        
        BOOL trace = NO;
        
        for (int i = 0; i < nframes; i++) {
            
            NSString* frame = [NSString stringWithCString:syms[i] encoding:NSUTF8StringEncoding];
            NSArray* items = [frame captures:@"^\\d+\\s+(\\w+)\\s+[a-z0-9]x[a-z0-9]+ (.*) \\+ \\d+$"];
            
            NSString* call = [items objectAtIndex:1];   
            
            if (trace) {                
                [stack addObject:[NSString stringWithFormat:@"{%@} %@", [items objectAtIndex:0], [items objectAtIndex:1]]];                                
            } else if (![call matches:@"^[+-]\\[NSObject(Debug) [^\\]]+]$"]) {            
                trace = YES;                    
            }            
        }
        
        free(syms);
        
        return stack;
    } 
    
    return nil;
}

- (void) debug {    
    NSString* trace = [[NSObject backtrace:3] lastObject];    
    NSLog(@"DEBUG %@\n%@\n\n", trace, [self generateDescription]);    
}

- (void) debug:(NSString*)format, ... {    
    va_list vargs;
    va_start(vargs, format);
    NSString* debug = [[NSString alloc] initWithFormat:format arguments:vargs];
    va_end(vargs);
    
    NSLog(@"DEBUG %@: %@", debug, [self generateDescription]);    
}

- (NSString *) generateDescription { 
    
    Class class = [self class];
    
	NSMutableString * classes = [[NSMutableString alloc] initWithFormat:@"%@", class];
    
	while (class != nil && ![class isEqual:[NSObject class]]) {
		[classes appendFormat:@":%@", class];
        class = class_getSuperclass(class); 
	}
    
	NSMutableString * properties = [[NSMutableString alloc] init];    
    
    for (NSString* property in [self properties]) {
        id value = [self valueForKey:property];          
        [properties appendFormat:@"  %@ %@ = %@;\n", [self propertyType:property], property, value];                        
    }
    
	return [NSString stringWithFormat:@"<%@> {\n%@}", classes, properties];
}




@end
