//
//  NSString+Match.m
//  GMno
//
//  Created by Mason Glaves on 3/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "NSString+Match.h"

@implementation NSString (Match)

- (BOOL) matches:(NSString*)pattern {

    NSRegularExpression* regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    
    return [regexp numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])] > 0;
        
}

@end
