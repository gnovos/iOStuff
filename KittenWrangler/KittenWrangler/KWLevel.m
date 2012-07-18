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

@synthesize level, bounds;

- (id) initLevel:(NSUInteger)lvl {
    if (self = [self init]) {
        
        level = lvl;
        timelimit = kKWTimeLimitMaxSeconds - (kKWTimeLimitLevelCost * level);

        bounds  = [UIScreen mainScreen].bounds;
        baskets = [[NSMutableArray alloc] init];
        kittens = [[NSMutableArray alloc] init];
        toys    = [[NSMutableArray alloc] init];

        [baskets addObject:[[KWBasket alloc] initWithLevel:self]];
        
        for (int i = 0; i < level; i++) {
            [kittens addObject:[[KWKitten alloc] initWithLevel:self]];
        }
    }
    return self;
}

- (BOOL) timeout { return [[NSDate date] timeIntervalSinceDate:start] > timelimit; }

- (NSArray*) objects {
    //xxxx
    return nil;
}

- (BOOL) complete { return kittens.count == 0 || [self timeout]; }

- (void) tick:(CGFloat)dt {    
    if (start == nil) {
        start = [NSDate date];
        return;
    }
    
//    dlog(@"tick:%f %@", dt, self);
        
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

//- (NSArray*) visibleFrom:(CGPoint)loc atAngle:(CGFloat)angle {
//    
//    CGPoint d = { sin(angle / 180.0 * M_PI), sin((angle + kKWRotate90Degrees) / kKWRotate180Degrees) };
//    
//    CGFloat slope = d.x ? (d.y / d.x) : MAXFLOAT;
//    
//    CGFloat mx = CGRectGetMidX(other.bounds);
//    CGFloat my = mx * slope;
//    
//    return CGRectContainsPoint(other.bounds, CGPointMake(mx, my));
//
//    
//}



- (NSString*) description {
    return [NSString stringWithFormat:@"level:%d limit:%d/%ds baskets:%d kittens:%d toys:%d",
            level,
            (int)[[NSDate date] timeIntervalSinceDate:start], timelimit,
            baskets.count,
            kittens.count,
            toys.count];
}


@end
