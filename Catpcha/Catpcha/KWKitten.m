//
//  KWKitten.m
//  Catpcha
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWKitten.h"
#import "KWLevel.h"
#import "KWToy.h"

@interface KWKitten ()

@end

typedef enum {
    KWKittenStateSleeping,
    KWKittenStateSitting,
    KWKittenStateStalking,
    KWKittenStateChasing,
    KWKittenStateExploring,
    KWKittenStateHeld,
    KWKittenStateCaptured
} KWKittenState;

typedef enum {
    KWKittenMoodBored      = 0,
    KWKittenMoodInterested = 5,
    KWKittenMoodExcited    = 7,
    KWKittenMoodCaptured   = 10
} KWKittenMood;

typedef enum {
    KWKittenEnergyTired    = 0,
    KWKittenEnergyExcited  = 50
} KWKittenEnergy;

@implementation KWKitten {
    CGFloat mood;
    CGFloat energy;
    
    KWKittenState state;
    
    KWObject* chasing;
}

@synthesize basket;

- (NSString*) description {
    return [[super description] stringByAppendingFormat:@" mood:%d energy:%d chasing:%@", (int)mood, (int)energy, self.chasing ? @"YES" : @"NO"];
}

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:kKWDefaultKittenSize]) {
        UIBezierPath* shape = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
        [shape addLineToPoint:CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f - 10.0f)];
        [shape addLineToPoint:CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f + 10.0f)];
        [shape addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height / 2.0f)];
        self.path = shape.CGPath;
        self.lineWidth = 1.0f;
        self.strokeColor = [UIColor blueColor].CGColor;
        
        self.touchable = YES;
        mood = KWKittenMoodBored;
        energy = arc4random_uniform(KWKittenEnergyExcited);
    }
    return self;
}

- (BOOL) idle      { return state == KWKittenStateSitting || state == KWKittenStateSleeping; }
- (BOOL) stalking  { return state == KWKittenStateStalking; }
- (BOOL) exploring { return state == KWKittenStateExploring;}
- (BOOL) chasing   { return chasing != nil && state == KWKittenStateChasing; }

- (BOOL) bored     { return mood <= KWKittenMoodBored; }
- (BOOL) tired     { return energy <= KWKittenEnergyTired; }

- (BOOL) moving    { return !self.captured && !self.touch && self.velocity > KWObjectVelocityMotionless; }

- (KWObjectVelocity) velocityForState:(KWKittenState)st {
    switch (st) {
        case KWKittenStateHeld:
        case KWKittenStateCaptured:
        case KWKittenStateSitting:
        case KWKittenStateSleeping:
            return KWObjectVelocityMotionless;
            
        case KWKittenStateStalking:
            return KWObjectVelocitySlow;
            
        case KWKittenStateExploring:
            return KWObjectVelocityAverage;
            
        default:
            return KWObjectVelocityFast;
    }
}

- (void) setState:(KWKittenState)st {
    self.velocity = [self velocityForState:st];
    state = st;
}

- (BOOL) captured { return basket != nil; }
- (void) setBasket:(KWBasket*)bskt {
    basket = bskt;
    if (bskt) {
        [self chase:nil];
        mood = KWKittenMoodCaptured + kKWRandom(KWKittenMoodCaptured);
        self.state = KWKittenStateCaptured;
    } else {
        self.state = KWKittenStateSitting;
    }
}

- (CGFloat) interest { return kKWRandomPercent; }

- (void) chase:(KWObject*)chase {
    chasing = chase;
    self.state = (chasing != nil) ? KWKittenStateChasing : KWKittenStateExploring;
}

- (BOOL) tick:(CGFloat)dt {
    if (self.captured) {
        if (self.bored) { self.basket = nil; }
    } else if (self.tired) {
        [self chase:nil];
        self.state = KWKittenStateSleeping;
    } else if (self.bored) {
        [self chase:nil];
        self.state = KWKittenStateExploring;
        self.heading += kKWRandomHeading;
        mood = KWKittenMoodInterested;
    } if (self.chasing) {
        CGPoint p = self.position;
        CGPoint c = chasing.position;
        
        CGFloat slope = (p.x - c.x) / (p.y - c.y);
        
        CGFloat angle = -radiansToDegrees(atanf(slope));
        
        angle += (p.y > c.y) ? -90 : 90;
        
        self.heading = angle;
        
    } else {
        [[self.level sight:self] enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
            if (obj.allure > self.interest) {
                [self chase:obj];
                mood += KWKittenMoodExcited * obj.allure;
                *stop = YES;
            }
        }];
    }

    if (self.idle) {
        mood -= MIN(dt, kKWRandomPercent);
        energy += dt;
    } else {
        mood -= dt * kKWRandomPercent;
        energy -= MIN(dt, kKWRandomPercent);
    }

    
    UIColor* color = [UIColor blueColor];
    self.lineDashPattern = nil;
    if (self.touch) {
        color = UIColor.brownColor;
    } else if (self.captured) {
        color = UIColor.orangeColor;
        self.lineDashPattern = @[@5, @5];
    } else if (self.idle) {
        color = UIColor.lightGrayColor;
        self.lineDashPattern = @[@2, @2];
    } else if (self.chasing) {
        color = UIColor.redColor;
    }
        
    self.strokeColor = color.CGColor;
        
    return [super tick:dt];
    
}



@end
