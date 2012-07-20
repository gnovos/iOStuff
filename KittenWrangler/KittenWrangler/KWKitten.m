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

- (BOOL) idle      { return self.velocity == KWKittenActionIdle;           }
- (BOOL) stalking  { return self.velocity == KWKittenActionStalk;          }
- (BOOL) exploring { return self.velocity == KWKittenActionExplore;        }
- (BOOL) chasing   { return chase && self.velocity == KWKittenActionChase; }

- (BOOL) bored     { return mood          <= KWKittenMoodBored;            }
- (BOOL) tired     { return energy        <= KWKittenEnergyTired;          }

- (void) turn:(CGFloat)dt {
    if (chase) {
        self.heading += [self directionOf:chase];
        self.velocity = KWKittenActionChase;//chase.velocity;
    }
}

- (BOOL) interested { return arc4random_uniform(100) / 100.0f > kKWKittenInterest;  }

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
        mood -= dt;
        energy += dt;
    } else {
        mood -= dt; //xxx should go down less quickly than above
        energy -= dt;
    }
                        
    [self  turn:dt];
    [super tick:dt];
}

- (NSString*) description {
    return [[super description] stringByAppendingFormat:@" mood:%d energy:%d chasing:%@", (int)mood, (int)energy, self.chasing ? @"YES" : @"NO"];
}


@end
