//
//  UIView+LLUtil.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "UIView+LL.h"
#import <objc/runtime.h>

@implementation UIView (LL)

- (CGPoint) origin { return self.frame.origin; }
- (void) setOrigin:(CGPoint)origin { self.frame = (CGRect) { origin, self.frame.size }; }

- (CGSize) size { return self.frame.size; }
- (void) setSize:(CGSize)size { self.frame = (CGRect) { self.frame.origin, size }; }

- (CGFloat) width { return self.frame.size.width; }
- (void) setWidth:(float)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat) height { return self.frame.size.height; }
- (void) setHeight:(float)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;}

- (CGFloat) x { return self.frame.origin.x; }
- (void) setX:(float)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;}

- (CGFloat) y { return self.frame.origin.y; }
- (void) setY:(float)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void) setBorderWidth:(CGFloat)width {
    self.layer.borderWidth = width;
}

- (void) setBorderColor:(UIColor*)color {
    self.layer.borderColor = [color CGColor];
}

- (void) setBorderRounding:(CGFloat)radius {
    self.layer.cornerRadius = radius;
}


@end
