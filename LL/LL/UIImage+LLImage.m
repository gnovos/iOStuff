//
//  UIImage+MMImage.m
//  Motif MVP Mobile
//
//  Created by Mason on 9/27/12.
//  Copyright (c) 2012 Blazing Cloud. All rights reserved.
//

#import "UIImage+LLImage.h"

@implementation UIImage (LLImage)

+ (UIImage*) imageFromPath:(NSString*)path {
    UIImage* image = nil;
    if ([path hasPrefix:@"http://"] || [path hasPrefix:@"file://"]) {
        NSURL* url = [NSURL URLWithString:path];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    } else {
        image = [UIImage imageNamed:path];
    }
    return image;
}

@end
