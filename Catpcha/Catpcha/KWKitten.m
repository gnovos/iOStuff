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
@property (nonatomic, assign) BOOL capture;
@end

typedef enum {
    KWKittenStateSleeping,
    KWKittenStateSitting,
    KWKittenStateStalking,
    KWKittenStateExploring,
    KWKittenStateChasing,
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

@dynamic capture;

- (NSString*) description {
    return [[super description] stringByAppendingFormat:@" mood:%d energy:%d chasing:%@", (int)mood, (int)energy, self.chasing ? @"YES" : @"NO"];
}

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:kKWDefaultKittenSize]) {
        mood = KWKittenMoodBored;
        energy = arc4random_uniform(KWKittenEnergyExcited);
    }
    return self;
}

- (BOOL) idle      { return state == KWKittenStateSitting || state == KWKittenStateSleeping; }
- (BOOL) stalking  { return state == KWKittenStateStalking; }
- (BOOL) exploring { return state == KWKittenStateExploring;}
- (BOOL) chasing   { return state == KWKittenStateChasing; }

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
            
        case KWKittenStateChasing:
            return KWObjectVelocityFast;
    }
}

- (void) setState:(KWKittenState)st {
    self.velocity = [self velocityForState:st];
    state = st;
}

- (BOOL) captured { return self.capture; }
- (void) setCaptured:(BOOL)cap {
    self.capture = cap;
    if (cap) {
        mood = KWKittenMoodCaptured + kKWRandom(KWKittenMoodCaptured);
        self.state = KWKittenStateCaptured;
    }
}

- (void) turn:(CGFloat)dt {
    if (chasing) {
        self.heading += [self directionOf:chasing];
        self.state = KWKittenStateChasing;
    }
}

- (BOOL) interested { return kKWRandomPercent > kKWKittenInterest;  }

- (void) explore {
    self.state = KWKittenStateExploring;
    self.heading += kKWRandomHeading;
    mood = KWKittenMoodInterested;
    chasing = nil;
    [[self.level sight:self] enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KWToy class]] || (obj.moving && [self interested])) {
            chasing = obj;
            self.state = KWKittenStateChasing;
            mood += KWKittenMoodExcited;
            if ([obj isKindOfClass:[KWToy class]]) {
                mood += KWKittenMoodExcited;
            }
            *stop = YES;            
        }
    }];    
}

- (void) tick:(CGFloat)dt {
    if (self.tired) {
        self.state = KWKittenStateSleeping;
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

- (void) drawInContext:(CGContextRef)ctx {
    KWGFX* gfx = [[KWGFX alloc] initWithContext:ctx];
    
    CGFloat inner = 2.0f;
    
    CGRect bounds = CGRectInset(self.bounds, inner, inner);
    
    
    UIColor* color = [UIColor blueColor];
    if (self.touch) {
        color = UIColor.brownColor;
    } else if (self.idle) {
        color = UIColor.lightGrayColor;
    } else if (self.chasing) {
        color = UIColor.redColor;
    } else if (self.captured) {
        color = UIColor.orangeColor;
    }
        
    [gfx stroke:color];
    
    if (self.captured) {
        [gfx dash:10.0f off:3.0f];
    } else {
        [[[gfx font:@"Helvetica Bold" size:12.0f] at:KWCGRectCenter(bounds)] text:@">"];
    }
    
    [gfx elipse:bounds];            
}


@end
