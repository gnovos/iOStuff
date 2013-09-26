//
//  UIImage+MMImage.h
//  Motif MVP Mobile
//
//  Created by Mason on 9/27/12.
//  Copyright (c) 2012 Blazing Cloud. All rights reserved.
//

@interface UIImage (LL)

+ (UIImage*) imageWithPath:(NSString*)path;

- (NSData*) jpgData;
- (NSData*) pngData;

@end
