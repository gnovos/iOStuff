//
//  KWKitten.m
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWKitten.h"
#import "KWLevel.h"

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
    
    //xxx especially this
    KWKitten* chasing;
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
        self.state = KWKittenStateSleeping;
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

- (void) drawInContext:(CGContextRef)ctx {
    KWGFX* gfx = [[KWGFX alloc] initWithContext:ctx];
    
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
    
    if (self.touch) {
        color = UIColor.brownColor;
    }
    
    [gfx stroke:color];
    
    if (self.captured) {
        [gfx dash:10.0f off:3.0f];
    } else {
        [[[gfx font:@"Helvetica Bold" size:12.0f] x:d.x y:d.y] text:@">"];
    }
    
    [gfx elipse:bounds];            
}


@end
