//
//  UIView+LLUtil.h
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

@interface UIView (LL)

- (CGPoint) origin;
- (void) setOrigin:(CGPoint)origin;
- (CGSize) size;
- (void) setSize:(CGSize)size;
- (CGFloat) width;
- (void) setWidth:(float)width;
- (CGFloat) height;
- (void) setHeight:(float)height;
- (CGFloat) x;
- (void) setX:(float)x;
- (CGFloat) y;
- (void) setY:(float)y;

- (void) setBorderWidth:(CGFloat)width;
- (void) setBorderColor:(UIColor*)color;
- (void) setBorderRounding:(CGFloat)radius;

- (void) clearActions;
- (void) setAction:(NSDictionary*)action;
- (void) addActions:(NSArray*)action;
- (void) addAction:(NSDictionary*)action;

@end
