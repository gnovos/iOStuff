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

static const int kKWTimeLimitMaxSeconds = 10 * 60;
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
        
        for (int i = 0; i < level * kKWKittensPerLevel; i++) {
            [kittens addObject:[[KWKitten alloc] initWithLevel:self]];
        }
    }
    return self;
}

- (NSTimeInterval) remaining {
    return timelimit - [[NSDate date] timeIntervalSinceDate:start];
}

- (BOOL) timeout { return self.remaining <= 0; }

- (BOOL) complete { return kittens.count == 0 || [self timeout]; }

- (void) tick:(CGFloat)dt {    
    if (start == nil) {
        start = [NSDate date];
        return;
    }
    
    [baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *stop) {
        [basket.kittens enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
            if (kitten.bored) {
                [kittens addObject:kitten];
            }
        }];
        [basket.kittens removeObjectsInArray:kittens];
    }];
    
    [kittens enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
        [kitten tick:dt];
    }];
        
}

- (void) move:(KWKitten*)kitten toBasket:(KWBasket*)basket {
    [kittens removeObject:kitten];
    [baskets makeObjectsPerformSelector:@selector(removeKitten:) withObject:kitten];
    [basket addKitten:kitten];
}

- (BOOL) vacant:(CGRect)rect excluding:(KWObject*)obj {
    
    __block BOOL vacant = YES;
    
    void (^block) (KWObject* o, NSUInteger idx, BOOL *stop) = ^(KWObject* o, NSUInteger idx, BOOL *stop) {
        
        if (o != obj && CGRectIntersectsRect(rect, o.bounds)) {
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

- (NSArray*) visible:(KWObject*)obj {
    
    CGPoint d = { sin(obj.rotation / 180.0 * M_PI), sin((obj.rotation + kKWAngle90Degrees) / kKWAngle180Degrees) };
    
    CGFloat slope = d.x ? (d.y / d.x) : 0;
    
    NSMutableArray* visible = [[NSMutableArray alloc] init];
        
    void (^block) (KWObject* obj, NSUInteger idx, BOOL *stop) = ^(KWObject* obj, NSUInteger idx, BOOL *stop) {
        
        CGFloat mx = CGRectGetMidX(obj.bounds);
        CGFloat my = obj.bounds.origin.x * slope;
        
        if (CGRectContainsPoint(obj.bounds, CGPointMake(mx, my))) {
            [visible addObject:obj];
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
