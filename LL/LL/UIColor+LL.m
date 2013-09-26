//
//  UIColor+MMHex.m
//  Motif MVP Mobile
//
//  Created by Blazing Pair on 9/28/12.
//  Copyright (c) 2012 Blazing Cloud. All rights reserved.
//

#import "UIColor+LL.h"
#import "NSString+LL.h"

@implementation UIColor (LL)

+ (UIColor*) colorWithString:(NSString*)color {
    static NSRegularExpression* regex;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString* pattern = @"^#?(?:([0-9A-F])([0-9A-F])([0-9A-F])([0-9A-F])?|([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})?)$";
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    
    color = color.lowercaseString;
    
    SEL uicolor = NSSelectorFromString([color stringByAppendingString:@"Color"]);
    if ([UIColor respondsToSelector:uicolor]) {
        return [UIColor performSelector:uicolor];
    }
    
    NSArray* rgba = [color capture:regex];
    
    NSMutableString* hexcolor = [NSMutableString string];
    [rgba enumerateObjectsUsingBlock:^(NSString* hex, NSUInteger idx, BOOL *stop) {
        [hexcolor appendString:hex];
        if (hex.length == 1) { [hexcolor appendString:hex]; }
    }];
    if (hexcolor.length == 6) {
        [hexcolor appendString:@"ff"];
    }
    
    unsigned int icolor;
    [[NSScanner scannerWithString:hexcolor] scanHexInt:&icolor];
    
    float red   = ((icolor >> 24) & 0xFF)/255.0f;
    float green = ((icolor >> 16) & 0xFF)/255.0f;
    float blue  = ((icolor >> 8)  & 0xFF)/255.0f;
    float alpha = ((icolor >> 0)  & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];}

@end
