//
//  NSString+LLUtil.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "NSString+LL.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (LL)

+ (NSString*) digest:(unsigned char*)digest length:(int)length {
    NSMutableString* hex = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        [hex appendFormat:@"%02x", digest[i]];
    }
    return hex;
}

- (NSString*) md5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), digest);
    return [NSString digest:digest length:CC_MD5_DIGEST_LENGTH];
}

- (NSString*) sha1 {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), digest);
    return [NSString digest:digest length:CC_SHA1_DIGEST_LENGTH];
}

- (BOOL) matches:(id)pattern {
    NSRegularExpression* regexp;
    if ([pattern isKindOfClass:NSRegularExpression.class]) {
        regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
        
    } else {
        regexp = [NSRegularExpression regularExpressionWithPattern:[pattern stringValue] options:0 error:NULL];
    }

    return [regexp numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0;
}

- (NSString*) match:(id)pattern {
    
    NSRegularExpression* regexp;
    if ([pattern isKindOfClass:NSRegularExpression.class]) {
        regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
        
    } else {
        regexp = [NSRegularExpression regularExpressionWithPattern:[pattern stringValue] options:0 error:NULL];        
    }
    
    NSTextCheckingResult* match = [regexp firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    
    for (NSUInteger i = 1; i <= [match numberOfRanges]; i++) {
        NSRange range = [match rangeAtIndex:i];
        if (range.location != NSNotFound) {
            return [self substringWithRange:range];
        }
    }
    
    return nil;
}

- (NSArray*) capture:(id)pattern {
    
    NSRegularExpression* regexp;
    
    if ([pattern isKindOfClass:NSRegularExpression.class]) {
        regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
        
    } else {
        regexp = [NSRegularExpression regularExpressionWithPattern:[pattern stringValue] options:0 error:NULL];
    }
    
    NSMutableArray* captures = [[NSMutableArray alloc] init];
    
    NSArray* matches = [regexp matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    for (NSTextCheckingResult* match in matches) {
        
        for (NSUInteger i = 1; i < [match numberOfRanges]; i++) {
            NSRange range = [match rangeAtIndex:i];
            if (range.location != NSNotFound) {
                [captures addObject:[self substringWithRange:range]];
            }
        }
    }
    
    return captures;
}

- (NSArray*) split:(NSString*)delimiter {
    return [self componentsSeparatedByString:delimiter];
}

- (BOOL) empty {
    return self.length == 0 || [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
}

- (BOOL) notEmpty {
    return !self.empty;
}




@end
