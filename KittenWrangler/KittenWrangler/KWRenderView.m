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
#import "KWBasket.h"

@implementation KWRenderView {
    KWEngine* engine;
    CADisplayLink* loop;
    NSMutableDictionary* tracking;
}

- (void) setup {
    engine = [[KWEngine alloc] init];
    tracking = [[NSMutableDictionary alloc] init];
    //xxx use a better rendering engine
    loop = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
    
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
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
    
    [level.baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *stop) {
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextAddRect(context, basket.bounds);
        CGContextStrokePath(context);
        
        [basket.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
            
            CGContextSetLineWidth(context, 2.0);
            
            CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
            
            CGFloat dashArray[] = {10,3};
            
            CGContextSetLineDash(context, idx, dashArray, 2);
            
            CGContextAddEllipseInRect(context, k.bounds);
            
            CGContextStrokePath(context);
        }];
        
        CGContextSetLineDash(context, 0, NULL, 0);
    }];
    
    [level.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
        CGContextSetLineWidth(context, 2.0);
        UIColor* color = k.idle ? [UIColor lightGrayColor] : [UIColor blueColor];        
        if (k.chased) {
            color = UIColor.yellowColor;
            CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
        }
        if (k.chasing) {
            color = UIColor.redColor;
        }
        if (k.held) {
            color = UIColor.brownColor;
        }

        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextAddEllipseInRect(context, k.bounds);
        CGContextStrokePath(context);
    }];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [touches enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
        CGPoint loc = [touch locationInView:self];
        KWLevel* level = engine.level;
        [level.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
            if (CGRectContainsPoint(k.bounds, loc)) {
                //xxx associate with touch
                k.held = YES;
            }
        }];
    }];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
        CGPoint loc = [touch previousLocationInView:self];
        KWLevel* level = engine.level;
        [level.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
            if (k.held && CGRectContainsPoint(k.bounds, loc)) {
                CGRect bounds = k.bounds;
                bounds.origin = [touch locationInView:self];
                bounds.origin.x -= bounds.size.width / 2.0f;
                bounds.origin.y -= bounds.size.height / 2.0f;
                k.bounds = bounds;
            }            
        }];
        
    }];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
        CGPoint loc = [touch previousLocationInView:self];
        KWLevel* level = engine.level;
        
        __block NSMutableDictionary* drops = [[NSMutableDictionary alloc] init];
        [level.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
            if (k.held && CGRectContainsPoint(k.bounds, loc)) {
                [level.baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *stop) {
                    if (CGRectContainsPoint(basket.bounds, k.center)) {
                        NSMutableArray* kits = [drops objectForKey:basket];
                        if (kits == nil) {
                            kits = [[NSMutableArray alloc] init];
                            [drops setObject:kits forKey:basket];
                        }
                        [kits addObject:k];
                        *stop = YES;
                    }
                }];
                
                k.held = NO;
                CGRect bounds = k.bounds;
                bounds.origin = [touch locationInView:self];
                bounds.origin.x -= bounds.size.width / 2.0f;
                bounds.origin.y -= bounds.size.height / 2.0f;
            }
        }];

        [drops enumerateKeysAndObjectsUsingBlock:^(KWBasket* basket, NSArray* kits, BOOL *stop) {
            [kits enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
                [level move:k toBasket:basket];
            }];
        }];        

    }];
}

@end
