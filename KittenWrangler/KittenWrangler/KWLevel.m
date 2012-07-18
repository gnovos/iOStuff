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

static const NSUInteger kKWTimeLimitMaxSeconds = 10 * 60;
static const NSUInteger kKWTimeLimitLevelCost  = 30;

@implementation KWLevel {
    
    NSMutableArray* baskets;
    NSMutableArray* kittens;
    NSMutableArray* toys;
    NSUInteger level;
    
    NSUInteger timelimit;
    
    NSDate* start;

}

@synthesize level, bounds, baskets, kittens, toys;

- (id) initLevel:(NSUInteger)lvl {
    if (self = [self init]) {
        
        level = lvl;
        timelimit = kKWTimeLimitMaxSeconds - (kKWTimeLimitLevelCost * level);

        bounds  = [UIScreen mainScreen].bounds;
        baskets = [[NSMutableArray alloc] init];
        kittens = [[NSMutableArray alloc] init];
        toys    = [[NSMutableArray alloc] init];

        [baskets addObject:[[KWBasket alloc] initWithLevel:self]];
        
        for (int i = 0; i < level * 3; i++) {
            [kittens addObject:[[KWKitten alloc] initWithLevel:self]];
        }
    }
    return self;
}

- (BOOL) timeout { return [[NSDate date] timeIntervalSinceDate:start] > timelimit; }

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
