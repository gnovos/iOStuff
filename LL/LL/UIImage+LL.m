//
//  UIImage+MMImage.m
//  Motif MVP Mobile
//
//  Created by Mason on 9/27/12.
//  Copyright (c) 2012 Blazing Cloud. All rights reserved.
//

#import "UIImage+LL.h"

@implementation UIImage (LL)

+ (UIImage*) imageWithPath:(NSString*)path {
    UIImage* image = nil;
    if ([path hasPrefix:@"http://"] || [path hasPrefix:@"file://"]) {
        NSURL* url = [NSURL URLWithString:path];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    } else {
        image = [UIImage imageNamed:path];
    }
    return image;
}

- (NSData*) jpgData { return UIImageJPEGRepresentation(self, 1.0); }

- (NSData*) pngData { return UIImagePNGRepresentation(self); }

@end
