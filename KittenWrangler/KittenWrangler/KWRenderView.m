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
    __block id slf = self;
    [engine add:^{ [slf setNeedsDisplay]; }];
    
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
}

- (id) initWithCoder:(NSCoder *)decoder { if (self = [super initWithCoder:decoder]) { [self setup]; } return self; }
- (id) initWithFrame:(CGRect)frame { if (self = [super initWithFrame:frame]) { [self setup]; } return self; }

- (void) start {
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

    UIColor* cfill = [UIColor colorWithRed:0.3F green:0.3f blue:0.5f alpha:0.2f];
    
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
    
    [level.baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *stop) {
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextAddRect(context, basket.layer.bounds);
        CGContextStrokePath(context);
        
        [basket.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
            
            CGContextSetLineWidth(context, 2.0);
            
            CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
            
            CGFloat dashArray[] = {10,3};
            
            CGContextSetLineDash(context, idx, dashArray, 2);
            
            CGContextAddEllipseInRect(context, k.layer.bounds);
            
            CGContextStrokePath(context);
            
            CGContextSetTextDrawingMode(context, kCGTextFill);
            CGContextSelectFont(context, "Helvetica Bold", 10.0f, kCGEncodingMacRoman);
            CGContextSetFillColorWithColor(context, UIColor.darkGrayColor.CGColor);
            
            const char* enfo = [[NSString stringWithFormat:@"       e: %.2f", k.energy] cStringUsingEncoding:NSUTF8StringEncoding];
            const char* mnfo = [[NSString stringWithFormat:@"       m: %.2f", k.mood] cStringUsingEncoding:NSUTF8StringEncoding];
            
            double text_angle = -M_PI / 180.0;
            CGAffineTransform xform = CGAffineTransformMake(cos(text_angle),  sin(text_angle),
                                                            sin(text_angle), -cos(text_angle),
                                                            0.0,  0.0);
            CGPoint d = k.center;
            CGContextSetTextMatrix(context, xform);
            CGContextShowTextAtPoint(context, d.x, d.y, enfo, strlen(enfo));
            CGContextShowTextAtPoint(context, d.x, d.y + 10.0f, mnfo, strlen(mnfo));
            CGContextStrokePath(context);
            
        }];
        
        CGContextSetLineDash(context, 0, NULL, 0);
    }];
    
    [level.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
        CGContextSetLineWidth(context, 2.0);
        UIColor* color = k.idle ? [UIColor lightGrayColor] : [UIColor blueColor];        
        if (k.chasing && k.chased) {
            color = UIColor.magentaColor;
        } else if (k.chasing) {
            color = UIColor.redColor;
        } else if (k.chased) {
            color = UIColor.yellowColor;
            CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
        }
        if (k.held) {
            color = UIColor.brownColor;
        }
        
        CGPoint d = k.center;
        
        CGContextSetFillColorWithColor(context, cfill.CGColor);
        CGContextAddEllipseInRect(context, k.layer.bounds);
        CGContextFillPath(context);
        
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextAddEllipseInRect(context, k.layer.bounds);
        CGContextStrokePath(context);
        
        CGContextSetTextDrawingMode(context, kCGTextFill);
        CGContextSelectFont(context, "Helvetica Bold", 10.0f, kCGEncodingMacRoman);
        CGContextSetFillColorWithColor(context, UIColor.darkGrayColor.CGColor);
        
        const char* enfo = [[NSString stringWithFormat:@"       e: %.2f", k.energy] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* mnfo = [[NSString stringWithFormat:@"       m: %.2f", k.mood] cStringUsingEncoding:NSUTF8StringEncoding];
        
        double text_angle = -M_PI / 180.0;
        CGAffineTransform xform = CGAffineTransformMake(cos(text_angle),  sin(text_angle),
                                                        sin(text_angle), -cos(text_angle),
                                                        0.0,  0.0);
        
        CGContextSetTextMatrix(context, xform);
        CGContextShowTextAtPoint(context, d.x, d.y, enfo, strlen(enfo));
        CGContextShowTextAtPoint(context, d.x, d.y + 10.0f, mnfo, strlen(mnfo));
        CGContextStrokePath(context);

        CGContextSelectFont(context, "Helvetica Bold", 12.0f, kCGEncodingMacRoman);
        CGContextSetFillColorWithColor(context, UIColor.purpleColor.CGColor);
        CGContextSetTextMatrix(context, CGAffineTransformMakeRotation(-degreesToRadians(k.heading)));
        CGContextShowTextAtPoint(context, d.x + 3 , d.y + 3, "^", 1);
        CGContextStrokePath(context);

        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextSetTextMatrix(context, CGAffineTransformMakeRotation(-degreesToRadians(k.rotation)));
        CGContextShowTextAtPoint(context, d.x + 3 , d.y + 3, "^", 1);
        CGContextStrokePath(context);
    }];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [touches enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
        CGPoint loc = [touch locationInView:self];
        KWLevel* level = engine.level;
        [level.kittens enumerateObjectsUsingBlock:^(KWKitten* k, NSUInteger idx, BOOL *stop) {
            if (CGRectContainsPoint(k.layer.bounds, loc)) {
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
            if (k.held && CGRectContainsPoint(k.layer.bounds, loc)) {
                CGRect bounds = k.layer.bounds;
                bounds.origin = [touch locationInView:self];
                bounds.origin.x -= bounds.size.width / 2.0f;
                bounds.origin.y -= bounds.size.height / 2.0f;
                k.layer.bounds = bounds;
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
            if (k.held && CGRectContainsPoint(k.layer.bounds, loc)) {
                [level.baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *stop) {
                    if (CGRectContainsPoint(basket.layer.bounds, k.center)) {
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
                CGRect bounds = k.layer.bounds;
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
