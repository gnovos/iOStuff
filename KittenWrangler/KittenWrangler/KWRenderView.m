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

//xxx use a better rendering engine than this horrible thing

@implementation KWRenderView {
    KWEngine* engine;
    NSMutableDictionary* tracking;
}

- (void) setup {
    engine = [[KWEngine alloc] init];
    tracking = [[NSMutableDictionary alloc] init];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
    
    id slf = self;
    [engine add:^{ [slf reset]; }];
    
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
}

- (id) initWithCoder:(NSCoder *)decoder { if (self = [super initWithCoder:decoder]) { [self setup]; } return self; }
- (id) initWithFrame:(CGRect)frame { if (self = [super initWithFrame:frame]) { [self setup]; } return self; }

- (void) reset {
    
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    [engine.level.baskets enumerateObjectsUsingBlock:^(KWBasket* b, NSUInteger idx, BOOL *stop) {
        [self.layer addSublayer:b];
    }];
    
    [engine.level.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
        [self.layer addSublayer:k];
    }];    
}

- (void) start {
    [self reset];
    [engine start];
}
- (void) pause { [engine pause]; }
- (void) stop  { [engine stop]; }

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    KWLevel* level = engine.level;
    
    const char* label = [[NSString stringWithFormat:@"Level %d (%d s)", level.level, (int)level.remaining] cStringUsingEncoding:NSUTF8StringEncoding];
    
    UIColor* tfill = [UIColor colorWithRed:(0.5f * level.remaining) green:0.3f blue:0.3f alpha:0.2f];
    UIColor* tstroke = [UIColor colorWithRed:0.5f green:0.5f blue:0.7f alpha:0.3f];
    
    CGContextSetStrokeColorWithColor(context, tstroke.CGColor);
    CGContextSetFillColorWithColor(context, tfill.CGColor);
    
	double text_angle = -M_PI/4.0;  // 45 Degrees counterclockwise
	CGAffineTransform xform = CGAffineTransformMake(cos(text_angle),  sin(text_angle),
                                                    sin(text_angle), -cos(text_angle),
                                                    0.0,  0.0);
    
	CGContextSetTextMatrix(context, xform);
	CGContextSelectFont(context, "Helvetica Bold", 38.f, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    CGContextShowTextAtPoint(context, 70, 350, label, strlen(label));
    
    CGContextSetStrokeColorWithColor(context, tfill.CGColor);
    CGFloat dash[] = {10,3};
    CGContextSetLineDash(context, 0, dash, 2);
    
    [level.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
        [[level sight:k] enumerateObjectsUsingBlock:^(KWObject* kk, NSUInteger idx, BOOL *stop) {
            CGContextMoveToPoint(context, k.position.x, k.position.y);
            CGContextAddLineToPoint(context, kk.position.x, kk.position.y);
        }];
    }];
    
    CGContextStrokePath(context);
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [touches enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
        CGPoint loc = [touch locationInView:self];
        KWLevel* level = engine.level;
        [level.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
            if (CGRectContainsPoint(k.frame, loc)) {
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
            if (k.held && CGRectContainsPoint(k.frame, loc)) {
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                k.position = [touch locationInView:self];
                [CATransaction commit];
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
            if (k.held && CGRectContainsPoint(k.frame, loc)) {
                [level.baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *stop) {
                    if (CGRectContainsPoint(basket.frame, k.position)) {
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
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                k.position = [touch locationInView:self];
                [CATransaction commit];
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
