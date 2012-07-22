//
//  KWKitten.m
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWKitten.h"
#import "KWLevel.h"

typedef enum {
    KWKittenActionIdle    = KWObjectVelocityMotionless,
    KWKittenActionStalk   = KWObjectVelocitySlow,
    KWKittenActionExplore = KWObjectVelocityAverage,
    KWKittenActionChase   = KWObjectVelocityFast
} KWKittenAction;

typedef enum {
    KWKittenMoodBored      = 0,
    KWKittenMoodInterested = 5,
    KWKittenMoodCaptured   = 10
} KWKittenMood;

typedef enum {
    KWKittenEnergyTired    = 0,
    KWKittenEnergyExcited  = 50
} KWKittenEnergy;

@implementation KWKitten {
    CGFloat mood;
    CGFloat energy;
    
    KWKitten* chase;
}

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:kKWDefaultKittenSize]) {
        mood = KWKittenMoodBored;
        energy = arc4random_uniform(KWKittenEnergyExcited);
    }
    return self;
}

- (CGFloat) mood { return mood; }
- (CGFloat) energy { return energy; }

- (BOOL) idle      { return self.velocity == KWKittenActionIdle;           }
- (BOOL) stalking  { return self.velocity == KWKittenActionStalk;          }
- (BOOL) exploring { return self.velocity == KWKittenActionExplore;        }
- (BOOL) chasing   { return chase && self.velocity == KWKittenActionChase; }

- (BOOL) bored     { return mood          <= KWKittenMoodBored;            }
- (BOOL) tired     { return energy        <= KWKittenEnergyTired;          }

- (void) capture   { mood = arc4random_uniform(KWKittenMoodCaptured) + KWKittenMoodCaptured; }

- (void) turn:(CGFloat)dt {
    //xxx
//    if (chase) {
//        self.heading += [self directionOf:chase];
//        self.velocity = KWKittenActionChase;//chase.velocity;
//    }
}

- (BOOL) interested { return kKWRandomPercent > kKWKittenInterest;  }

- (void) explore {
    self.velocity = KWKittenActionExplore;
    self.heading = kKWRandomHeading;
    mood = KWKittenMoodInterested;
    chase.chased = NO;
    chase = nil;
    
    [[self.level visible:self] enumerateObjectsUsingBlock:^(KWKitten* obj, NSUInteger idx, BOOL *stop) {
        if (obj.moving && [self interested]) {
            chase = obj;
            chase.chased = YES;
            *stop = YES;
        }
    }];    
}

- (void) tick:(CGFloat)dt {
    if (self.tired) {
        self.velocity = KWKittenActionIdle;
        chase.chased = NO;
        chase = nil;
    } else if (self.bored) {
        [self explore];
    }
    
    if (self.idle) {        
        mood -= MIN(dt, kKWRandomPercent);
        energy += dt;
    } else {
        mood -= dt * kKWRandomPercent;
        energy -= MIN(dt, kKWRandomPercent);
    }
                        
    [self  turn:dt];
    [super tick:dt];
    
}

- (NSString*) description {
    return [[super description] stringByAppendingFormat:@" mood:%d energy:%d chasing:%@", (int)mood, (int)energy, self.chasing ? @"YES" : @"NO"];
}

- (void) drawInContext:(CGContextRef)context {
    
    UIColor* color = self.idle ? [UIColor lightGrayColor] : [UIColor blueColor];
    if (self.chasing && self.chased) {
        color = UIColor.magentaColor;
    } else if (self.chasing) {
        color = UIColor.redColor;
    } else if (self.chased) {
        color = UIColor.yellowColor;
    }
    if (self.held) {
        color = UIColor.brownColor;
    }
    
    CGFloat inner = 3.0f;
    CGRect bounds = CGRectInset(self.bounds, inner, inner);

    CGPoint d = KWCGRectCenter(bounds);

    CGContextSetStrokeColorWithColor(context, color.CGColor);

    CGContextAddEllipseInRect(context, bounds);
    CGContextStrokePath(context);
    
    CGContextSelectFont(context, "Helvetica Bold", 12.0f, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextStroke);

    CGContextSetStrokeColorWithColor(context, UIColor.purpleColor.CGColor);
    CGContextShowTextAtPoint(context, d.x , d.y, ">", 1);
    CGContextStrokePath(context);
    
            
//    CGContextSelectFont(context, "Helvetica Bold", 12.0f, kCGEncodingMacRoman);
//    CGContextSetTextDrawingMode(context, kCGTextStroke);    
//    
//    CGContextSetStrokeColorWithColor(context, UIColor.purpleColor.CGColor);
//    CGContextSetTextMatrix(context, CGAffineTransformMakeRotation(-degreesToRadians(self.heading)));
//    CGContextShowTextAtPoint(context, d.x , d.y, "^", 1);
//    CGContextStrokePath(context);
//    
//    CGContextSetStrokeColorWithColor(context, color.CGColor);
//    CGContextSetTextMatrix(context, CGAffineTransformMakeRotation(-degreesToRadians(self.rotation)));
//    CGContextShowTextAtPoint(context, d.x, d.y, "^", 1);
//    CGContextStrokePath(context);
    
}


@end
