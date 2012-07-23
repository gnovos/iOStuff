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

//xxx do this better
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
    
    BOOL captured;
    
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

- (BOOL) idle      { return self.velocity == KWKittenActionIdle;             }
- (BOOL) stalking  { return self.velocity == KWKittenActionStalk;            }
- (BOOL) exploring { return self.velocity == KWKittenActionExplore;          }
- (BOOL) chasing   { return chasing && self.velocity == KWKittenActionChase; }

- (BOOL) bored     { return mood          <= KWKittenMoodBored;              }
- (BOOL) tired     { return energy        <= KWKittenEnergyTired;            }

- (BOOL) moving    { return !self.captured && !self.touch && self.velocity > KWObjectVelocityMotionless; }


- (BOOL) captured { return self.capture; }
- (void) setCaptured:(BOOL)cap {
    self.capture = cap;
    if (captured) {
        mood = KWKittenMoodCaptured + kKWRandom(KWKittenMoodCaptured);
        self.velocity = KWObjectVelocityMotionless;
    }
}

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
