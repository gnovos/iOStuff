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
    
    KWKitten* chasing;
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
- (BOOL) chasing   { return chasing && self.velocity == KWKittenActionChase; }

- (BOOL) bored     { return mood          <= KWKittenMoodBored;            }
- (BOOL) tired     { return energy        <= KWKittenEnergyTired;          }

- (void) turn:(CGFloat)dt {
    if (chasing) {
        self.heading += [self directionOf:chasing];
        self.velocity = KWKittenActionChase;//chase.velocity;
    }
}

- (BOOL) interested { return kKWRandomPercent > kKWKittenInterest;  }

- (void) explore {
    self.velocity = KWKittenActionExplore;
    self.heading += kKWRandomHeading;
    mood = KWKittenMoodInterested;
    chasing.chased = NO;
    chasing = nil;
    
    [[self.level sight:self] enumerateObjectsUsingBlock:^(KWKitten* obj, NSUInteger idx, BOOL *stop) {
        if (obj.moving && !obj.chased) {// && [self interested]) {
            chasing = obj;
            chasing.chased = YES;
            *stop = YES;
        }
    }];    
}

- (void) tick:(CGFloat)dt {
    if (self.tired) {
        self.velocity = KWKittenActionIdle;
        chasing.chased = NO;
        chasing = nil;
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
    CGFloat inner = 2.0f;
    
    CGRect bounds = CGRectInset(self.bounds, inner, inner);
    
    CGPoint d = KWCGRectCenter(bounds);
    
    UIColor* color = self.idle ? [UIColor lightGrayColor] : [UIColor blueColor];
    if (self.chasing && self.chased) {
        color = UIColor.magentaColor;
    } else if (self.chasing) {
        color = UIColor.redColor;
    } else if (self.chased) {
        color = UIColor.yellowColor;
    } else if (self.captured) {
        color = UIColor.orangeColor;
    }
    if (self.held) {
        color = UIColor.brownColor;
    }
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);

    if (self.captured) {
        CGFloat dash[] = {10,3};
        CGContextSetLineDash(context, 0, dash, 2);
    } else {
        CGContextSelectFont(context, "Helvetica Bold", 12.0f, kCGEncodingMacRoman);
        CGContextSetTextDrawingMode(context, kCGTextStroke);
//        CGContextSetStrokeColorWithColor(context, UIColor.purpleColor.CGColor);
        CGContextShowTextAtPoint(context, d.x , d.y, ">", 1);
        CGContextStrokePath(context);        
    }

    CGContextAddEllipseInRect(context, bounds);
    CGContextStrokePath(context);
            
}


@end
