//
//  NSObject+KWGFX.m
//  Catpcha
//
//  Created by Mason on 7/22/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWGFX.h"

@implementation KWGFX {
    CGContextRef ctx;
    CGPoint at;
}

+ (void) animate:(void(^)(void))animation {
    [self animate:0 animation:animation onComplete:nil];
}

+ (void) animate:(CFTimeInterval)duration animation:(void(^)(void))animation onComplete:(void(^)(void))completion {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (duration > 0) {
        [CATransaction setAnimationDuration:duration];
    } 
    if (completion) {
        [CATransaction setCompletionBlock:completion];
    }
    animation();
    [CATransaction commit];
}

+ (id) current { return [[self alloc] initWithContext:UIGraphicsGetCurrentContext()]; }

- (id) initWithContext:(CGContextRef)context {
    if (self = [super init]) {
        ctx = context;
    }
    return self;
}

- (CGContextRef) context { return ctx;}

- (id) fill:(UIColor*)fill {
    CGContextSetFillColorWithColor(ctx, fill.CGColor);
    return self;
}

- (id) stroke:(UIColor*)stroke {
    CGContextSetStrokeColorWithColor(ctx, stroke.CGColor); 
    return self;
}

- (id) angle:(CGFloat)degrees {
    CGFloat rads = degreesToRadians(degrees);
    CGContextSetTextMatrix(ctx, CGAffineTransformMake(cos(rads), sin(rads),
                                                      sin(rads), -cos(rads),
                                                      0.0,  0.0));
    return self;
}

- (id) font:(NSString*)name size:(CGFloat)size {
    CGContextSelectFont(ctx, [name cStringUsingEncoding:NSUTF8StringEncoding], size, kCGEncodingMacRoman);
    return self;
}

- (id) x:(CGFloat)x y:(CGFloat)y {
    at.x = x;
    at.y = y;
    return self;
}

- (id) x:(CGFloat)x {
    at.x = x;
    return self;
}

- (id) y:(CGFloat)y {
    at.y = y;
    return self;
}

- (id) at:(CGPoint)loc {
    at = loc;
    return self;
}

- (id) rect:(CGRect)rect {
    CGContextAddRect(ctx, rect);
    return self.stroke;
}

- (id) width:(CGFloat)width {
    CGContextSetLineWidth(ctx, width);
    return self;
}

- (id) line:(CGPoint)from to:(CGPoint)to {
    CGContextMoveToPoint(ctx, from.x, from.y);
    CGContextAddLineToPoint(ctx, to.x, to.y);
    return self.stroke;
}

- (id) to:(CGPoint)to {
    CGContextAddLineToPoint(ctx, to.x, to.y);
    return self.stroke;
}

- (id) elipse:(CGRect)rect {
    CGContextAddEllipseInRect(ctx, rect);
    return self.stroke;
}

- (id) dash:(CGFloat)on off:(CGFloat)off {
    CGFloat dash[] = {on, off};
    CGContextSetLineDash(ctx, 0, dash, 2);
    return self;
}

- (id) mode:(CGTextDrawingMode)mode {
    CGContextSetTextDrawingMode(ctx, mode);
    return self;
}

- (id) text:(NSString*)text {
    const char* label = [text cStringUsingEncoding:NSUTF8StringEncoding];
    CGContextShowTextAtPoint(ctx, at.x, at.y, label, strlen(label));
    return self.stroke;
}

- (id) stroke {
    CGContextStrokePath(ctx);
    return self;
}

- (id) fill {
    CGContextFillPath(ctx);
    return self;
}

- (id) felipse:(CGRect)rect {
    CGContextAddEllipseInRect(ctx, rect);
    return self.fill;
}

@end
