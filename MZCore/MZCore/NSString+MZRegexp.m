//
//  NSString+MZRegexp.m
//  MZCore
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "NSString+MZRegexp.h"

@implementation NSString (MZRegexp)

- (BOOL) matches:(NSString*)pattern {
    
    NSRegularExpression* regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    
    return [regexp numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])] > 0;    
}

- (NSString*) capture:(NSString*)pattern {
    
    NSRegularExpression* regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    
    NSTextCheckingResult* match = [regexp firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    
    for (int i = 1; i < [match numberOfRanges]; i++) {
        NSRange range = [match rangeAtIndex:i];
        if (range.location != NSNotFound) {
            return [self substringWithRange:range];
        }        
    }
    
    return nil;
}

- (NSArray*) captures:(NSString*)pattern {
    
    NSRegularExpression* regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    
    NSMutableArray* captures = [[NSMutableArray alloc] init];
    
    NSArray* matches = [regexp matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    for (NSTextCheckingResult* match in matches) {
        
        for (int i = 1; i < [match numberOfRanges]; i++) {
            NSRange range = [match rangeAtIndex:i];
            if (range.location != NSNotFound) {
                [captures addObject:[self substringWithRange:range]];
            }        
        }
        
        
    }
    
    return captures;
}


@end
