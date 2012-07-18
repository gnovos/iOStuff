//
//  KWRenderView.m
//  KittenWrangler
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWRenderView.h"
#import "KWEngine.h"
#import "KWLevel.h"
#import "KWObject.h"
#import "KWKitten.h"

@implementation KWRenderView {
    KWEngine* engine;
    CADisplayLink* loop;
}

- (void) setup {
    engine = [[KWEngine alloc] init];
    //xxx use a better rendering engine
    loop = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
}

- (id) initWithCoder:(NSCoder *)decoder { if (self = [super initWithCoder:decoder]) { [self setup]; } return self; }
- (id) initWithFrame:(CGRect)frame { if (self = [super initWithFrame:frame]) { [self setup]; } return self; }

- (void) start {
    [engine start];
    [loop addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void) pause { [engine pause]; }
- (void) stop  { [engine stop]; }

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    KWLevel* level = engine.level;
    
    [level.baskets enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextAddRect(context, obj.bounds);
        CGContextStrokePath(context);
    }];
    
    [level.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 2.0);
        UIColor* color = k.idle ? [UIColor redColor] : [UIColor blueColor];        
        if (k.chased) {
            color = UIColor.yellowColor;
            CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
        }
        if (k.chasing) {
            color = UIColor.lightGrayColor;
        }
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextAddEllipseInRect(context, k.bounds);
        CGContextStrokePath(context);
    }];
}
@end
