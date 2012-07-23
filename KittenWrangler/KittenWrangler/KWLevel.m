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
#import "KWMouse.h"
#import "KWToy.h"

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

- (NSString*) description {
    return [NSString stringWithFormat:@"level:%d limit:%d/%ds baskets:%d kittens:%d toys:%d",
            level, (int)[[NSDate date] timeIntervalSinceDate:start], timelimit,
            baskets.count, kittens.count, toys.count];
}

- (id) initLevel:(int)lvl {
    if (self = [self init]) {
        
        level = lvl;
        timelimit = kKWTimeLimitMaxSeconds - (kKWTimeLimitLevelCost * level);

        bounds  = [UIScreen mainScreen].bounds;
        baskets = [[NSMutableArray alloc] init];
        kittens = [[NSMutableArray alloc] init];
        toys    = [[NSMutableArray alloc] init];

        [baskets addObject:[[KWBasket alloc] initWithLevel:self]];
        for (int i = 0; i < level / 3; i++) {
            [baskets addObject:[[KWBasket alloc] initWithLevel:self]];
        }
        
        for (int i = 0; i < level * (kKWRandom(kKWKittensPerLevel) + kKWKittensPerLevel); i++) {
            [kittens addObject:[[KWKitten alloc] initWithLevel:self]];
        }
        
        [toys addObject:[[KWMouse alloc] initWithLevel:self]];
        
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
        [basket tick:dt];
    }];
    
    [toys enumerateObjectsUsingBlock:^(KWToy* toy, NSUInteger idx, BOOL *stop) {
        [toy tick:dt];
    }];
    
    [kittens enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
        [kitten tick:dt];
    }];
        
}

- (void) free:(NSArray*)kits {
    [kits enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
        [baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *stop) {
            [basket.kittens removeObject:kitten];
        }];
        kitten.captured = NO;
        [kittens addObject:kitten];
    }];
}
 
- (void) capture:(NSArray*)kits {
    [kits enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
        [kittens removeObject:kitten];
        kitten.captured = YES;
    }];
}

- (BOOL) vacant:(CGPoint)p excluding:(KWObject*)obj {
    
    __block BOOL vacant = YES;
    
    void (^block) (KWObject* o, NSUInteger idx, BOOL *stop) = ^(KWObject* o, NSUInteger idx, BOOL *stop) {
        if (o != obj && CGRectContainsPoint(o.frame, p)) {
            vacant = NO;
            *stop = YES;
        }
    };
    
    [baskets enumerateObjectsUsingBlock:block];
    
    if (vacant) { [kittens enumerateObjectsUsingBlock:block]; }
    if (vacant) { [toys enumerateObjectsUsingBlock:block];    }
    
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
                CGRect size = k.frame;
                if (size.size.width < o.frame.size.width || size.size.height < o.frame.size.height) {
                    size.size = o.frame.size;
                }
                
                if (CGRectContainsPoint(size, q)) {
                    [visible addObject:k];
                }            
            }
        }
    };
    
    [kittens enumerateObjectsUsingBlock:block];
    [toys enumerateObjectsUsingBlock:block];

    return visible;

}


@end
