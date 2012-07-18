//
//  KWKitten.m
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWKitten.h"
#import "KWLevel.h"

static const CGSize kKWDefaultKittenSize = { 20, 20 };

typedef enum {
    KWKittenActionIdle    = KWObjectVelocityMotionless,
    KWKittenActionStalk   = KWObjectVelocitySlow,
    KWKittenActionExplore = KWObjectVelocityAverage,
    KWKittenActionChase   = KWObjectVelocityFast
} KWKittenAction;

typedef enum {
    KWKittenMoodBored      = 0,
    KWKittenMoodInterested = 10,
} KWKittenMood;

typedef enum {
    KWKittenEnergyTired    = 0,
    KWKittenEnergyExcited  = 10
} KWKittenEnergy;

@implementation KWKitten {
    CGFloat mood;
    CGFloat energy;
    
    KWObject* chase;
}

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:kKWDefaultKittenSize]) {
        mood = KWKittenMoodBored;
        energy = KWKittenEnergyExcited;
    }
    return self;
}

- (BOOL) idle      { return self.velocity == KWKittenActionIdle;    }
- (BOOL) stalking  { return self.velocity == KWKittenActionStalk;   }
- (BOOL) exploring { return self.velocity == KWKittenActionExplore; }
- (BOOL) chasing   { return self.velocity == KWKittenActionChase;   }

- (BOOL) bored     { return mood          <= KWKittenMoodBored;     }
- (BOOL) tired     { return energy        <= KWKittenEnergyTired;   }

- (void) turn:(CGFloat)dt {
    if (chase) {
        self.heading = [self direction:chase];
        self.velocity = chase.velocity;
    }
}

- (void) explore {
    self.velocity = KWKittenActionExplore;
    self.heading = kKWRandomHeading;
    mood = KWKittenMoodInterested;
    chase = nil;
    
    //xxx
//    [self.level.objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
//        if ([self sees:obj] && obj.moving) {
//            //xxx make this a % chance?
//            chase = obj;
//            *stop = YES;
//        }
//    }];
}

- (void) tick:(CGFloat)dt {       
    if (self.tired) {
        self.velocity = KWKittenActionIdle;
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
    return [[super description] stringByAppendingFormat:@" mood:%d energy:%d chasing:%@", (int)mood, (int)energy, chase];
}


@end
