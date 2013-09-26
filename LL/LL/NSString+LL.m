//
//  NSString+LLUtil.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "NSString+LL.h"
#import "UIImage+LL.h"
#import "UIColor+LL.h"

@implementation NSString (LL)

- (BOOL) empty { return self.length == 0 || [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0; }
- (BOOL) unempty { return !self.empty; }
- (NSUInteger) count { return self.length; }
- (NSUInteger) size { return self.length; }

+ (NSString*) digest:(unsigned char*)digest length:(int)length {
    NSMutableString* hex = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        [hex appendFormat:@"%02x", digest[i]];
    }
    return hex;
}

+ (NSString *)uuid {
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return uuidString;
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
        regexp = pattern;
        
    } else {
        regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    }

    return [regexp numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0;
}

- (NSString*) match:(id)pattern {
    
    NSRegularExpression* regexp;
    if ([pattern isKindOfClass:NSRegularExpression.class]) {
        regexp = pattern;
        
    } else {
        regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
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
        regexp = pattern;
        
    } else {
        regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
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

- (NSArray*) split:(NSString*)delimiters {
    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:delimiters]];
}

- (NSString*) trim:(NSString*)characters {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:characters]];
}

- (id) obj {
    
    id obj = [UIImage imageWithPath:self];

    if (obj == nil) { obj = [UIColor colorWithString:self]; }
    
    return obj;
}

@end
