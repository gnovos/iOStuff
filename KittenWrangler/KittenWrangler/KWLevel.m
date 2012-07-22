//
//  KWField.m
//  KittenWrangler
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWLevel.h"
#import "KWBasket.h"
#import "KWKitten.h"

static const int kKWTimeLimitMaxSeconds = 3 * 60;
static const int kKWTimeLimitLevelCost  = 5;

@implementation KWLevel {
    
    NSMutableArray* baskets;
    NSMutableArray* kittens;
    NSMutableArray* toys;
    int level;
    
    NSUInteger timelimit;
    
    NSDate* start;

}

@synthesize level, bounds, baskets, kittens, toys;

- (id) initLevel:(int)lvl {
    if (self = [self init]) {
        
        level = lvl;
        timelimit = kKWTimeLimitMaxSeconds - (kKWTimeLimitLevelCost * level);

        bounds  = [UIScreen mainScreen].bounds;
        baskets = [[NSMutableArray alloc] init];
        kittens = [[NSMutableArray alloc] init];
        toys    = [[NSMutableArray alloc] init];

        [baskets addObject:[[KWBasket alloc] initWithLevel:self]];
        
        for (int i = 0; i < level * (arc4random_uniform(kKWKittensPerLevel) + kKWKittensPerLevel); i++) {
            [kittens addObject:[[KWKitten alloc] initWithLevel:self]];
        }
    }
    return self;
}

- (NSTimeInterval) remaining {
    return timelimit - [[NSDate date] timeIntervalSinceDate:start];
}

- (BOOL) timeout { return self.remaining <= 0; }

- (BOOL) complete {
    return kittens.count == 0 || [self timeout];
}

- (void) tick:(CGFloat)dt {    
    if (start == nil) {
        start = [NSDate date];
        return;
    }
    
    [baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *stop) {
        [basket.kittens enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
            if (kitten.bored) {
                [kittens addObject:kitten];
                *stop = YES;
            } else {
                [kitten tick:dt];
            }
        }];
        [basket.kittens removeObjectsInArray:kittens];
    }];
    
    [kittens enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
        [kitten tick:dt];
    }];
        
}

- (void) move:(KWKitten*)kitten toBasket:(KWBasket*)basket {
    kitten.captured = YES;
    [kittens removeObject:kitten];
    [baskets makeObjectsPerformSelector:@selector(removeKitten:) withObject:kitten];
    [basket addKitten:kitten];
}

- (BOOL) vacant:(CGPoint)p excluding:(KWObject*)obj {
    
    __block BOOL vacant = YES;
    
    //xxx do this better
    void (^block) (KWObject* o, NSUInteger idx, BOOL *stop) = ^(KWObject* o, NSUInteger idx, BOOL *stop) {
        if (o != obj && CGRectContainsPoint(o.frame, p)) {
            vacant = NO;
            *stop = YES;
        }
    };
    
    [baskets enumerateObjectsUsingBlock:block];
    
    if (vacant) {
        [kittens enumerateObjectsUsingBlock:block];
    }
    
    if (vacant) {
        [toys enumerateObjectsUsingBlock:block];
    }
    
    return vacant;
}

- (NSArray*) sight:(KWObject*)o {
    
    NSMutableArray* visible = [[NSMutableArray alloc] init];
    
    CGFloat rads = degreesToRadians(o.heading);
    
    CGPoint p = o.position;
    
    void (^block) (KWObject* obj, NSUInteger idx, BOOL *stop) = ^(KWObject* k, NSUInteger idx, BOOL *stop) {
        if (k != o) {
            CGPoint q = k.position;
                        
            CGFloat dist = p.x - q.x;
            CGFloat dir = cosf(rads);
            BOOL match = (dir < 0 && dist > 0) || (dir > 0 && dist < 0);
            
            if (match) {
                CGFloat m = tan(rads) * dist;
                q.y = p.y - m;
                if (CGRectContainsPoint(k.frame, q)) {
                    [visible addObject:k];
                }            
            }
        }
    };
    
    [kittens enumerateObjectsUsingBlock:block];
    
    [toys enumerateObjectsUsingBlock:block];

    return visible;

}

- (NSString*) description {
    return [NSString stringWithFormat:@"level:%d limit:%d/%ds baskets:%d kittens:%d toys:%d",
            level,
            (int)[[NSDate date] timeIntervalSinceDate:start], timelimit,
            baskets.count,
            kittens.count,
            toys.count];
}


@end
