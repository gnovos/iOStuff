//
//  NSObject+KWGFX.h
//  KittenWrangler
//
//  Created by Mason on 7/22/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWGFX : NSObject

+ (id) current;

- (id) initWithContext:(CGContextRef)context;

- (CGContextRef) context;
- (id) fill:(UIColor*)fill;
- (id) stroke:(UIColor*)stroke;
- (id) angle:(CGFloat)degrees;
- (id) font:(NSString*)name size:(CGFloat)size;
- (id) at:(CGPoint)loc;
- (id) x:(CGFloat)x y:(CGFloat)y;
- (id) x:(CGFloat)x;
- (id) y:(CGFloat)y;
- (id) rect:(CGRect)rect;
- (id) width:(CGFloat)width;
- (id) line:(CGPoint)from to:(CGPoint)to;
- (id) elipse:(CGRect)rect;
- (id) dash:(CGFloat)on off:(CGFloat)off;
- (id) text:(NSString*)text;
- (id) stroke;
- (id) fill;

@end
