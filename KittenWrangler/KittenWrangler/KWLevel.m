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

- (BOOL) complete { return kittens.count == 0 || [self timeout]; }

- (void) tick:(CGFloat)dt {    
    if (start == nil) {
        start = [NSDate date];
        return;
    }
    
    [baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *stop) {
//xxx fix this, particularly the exiting
//        [basket.kittens enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
//            if (kitten.bored) {
//                CGRect kbounds = kitten.layer.frame;
//                CGPoint exit = CGPointMake(basket.layer.frame.origin.x - kitten.layer.frame.size.height, CGRectGetMidY(basket.layer.frame));
//                if (exit.x < 0) {
//                    exit.x = CGRectGetMinY(basket.layer.frame) + 1.0f;
//                }
//                kbounds.origin = exit;
//                kitten.layer.frame = kbounds;
//                [kittens addObject:kitten];
//                *stop = YES;
//            } else {
//                [kitten tick:dt];
//            }
//        }];
//        [basket.kittens removeObjectsInArray:kittens];
    }];
    
    
    [kittens enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
        [kitten tick:dt];
    }];
    
        
}

- (void) move:(KWKitten*)kitten toBasket:(KWBasket*)basket {
    [kitten capture];
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

- (NSArray*) visible:(KWObject*)obj {
    ///xxx fix this
    
    NSMutableArray* visible = [[NSMutableArray alloc] init];

    ///xxx fix this
//    CGPoint d = { sin(obj.rotation / 180.0 * M_PI), sin((obj.rotation + kKWAngle90Degrees) / kKWAngle180Degrees) };
//    
//    CGFloat slope = d.x ? (d.y / d.x) : 0;
//    
//    void (^block) (KWObject* obj, NSUInteger idx, BOOL *stop) = ^(KWObject* obj, NSUInteger idx, BOOL *stop) {
//        
//        CGFloat mx = CGRectGetMidX(obj.layer.frame);
//        CGFloat my = obj.layer.position.x * slope;
//        
//        if (CGRectContainsPoint(obj.layer.frame, CGPointMake(mx, my))) {
//            [visible addObject:obj];
//        }
//        
//    };
//    
//    [kittens enumerateObjectsUsingBlock:block];
//    
//    [toys enumerateObjectsUsingBlock:block];

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
