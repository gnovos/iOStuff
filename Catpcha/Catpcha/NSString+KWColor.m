//
//  NSString+KWColor.m
//  Catpcha
//
//  Created by Mason on 8/14/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "NSString+KWColor.h"

@implementation NSString (KWColor)

- (GLKVector4) vColor {
    static NSRegularExpression* parser;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        parser = [NSRegularExpression regularExpressionWithPattern:@"^(?:#|0x)?(?:([0-9A-Z])([0-9A-Z])([0-9A-Z])([0-9A-Z])|([0-9A-Z]{2})([0-9A-Z]{2})([0-9A-Z]{2})([0-9A-Z]{2}))$"
                                                           options:NSRegularExpressionCaseInsensitive
                                                             error:NULL];
    });
    
    NSTextCheckingResult* match = [parser firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    
    GLfloat r = 1.0f, g = 0.5f, b = 0.5f, a = 1.0f;
    
    for (int i = 1; i < [match numberOfRanges]; i++) {
        NSRange range = [match rangeAtIndex:i];
        if (range.location != NSNotFound) {
            NSString* s = [self substringWithRange:range];
            long channel = strtol([s UTF8String], NULL, 16);
            switch (i) {
                case 1:
                    r = (channel * 2.0f) / 255.0f;
                    break;
                case 2:
                    g = (channel * 2.0f) / 255.0f;
                    break;
                case 3:
                    b = (channel * 2.0f) / 255.0f;
                    break;
                case 4:
                    a = (channel * 2.0f) / 255.0f;
                    break;
                case 5:
                    r = channel / 255.0f;
                    break;
                case 6:
                    g = channel / 255.0f;
                    break;
                case 7:
                    b = channel / 255.0f;
                    break;
                case 8:
                    a = channel / 255.0;
                    break;
            }        
        }
    }
    
    NSLog(@"%@ r:%f g:%f b:%f a:%f", self, r, g, b, a);

    return GLKVector4Make(r, g, b, a);
}

@end


/*
 unsigned result = 0;
 NSScanner *scanner = [NSScanner scannerWithString:@"#01FFFFAB"];
 
 [scanner setScanLocation:1]; // bypass '#' character
 [scanner scanHexInt:&result];

 int main ()
 {
 char szNumbers[] = "2001 60c0c0 -1101110100110100100000 0x6fffff";
 char * pEnd;
 long int li1, li2, li3, li4;
 li1 = strtol (szNumbers,&pEnd,10);
 li2 = strtol (pEnd,&pEnd,16);
 li3 = strtol (pEnd,&pEnd,2);
 li4 = strtol (pEnd,NULL,0);
 printf ("The decimal equivalents are: %ld, %ld, %ld and %ld.\n", li1, li2, li3, li4);
 return 0;
 }
 */