//
//  KWField.m
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWLevel.h"
#import "KWBasket.h"
#import "KWKitten.h"
#import "KWMouse.h"
#import "KWToy.h"
#import "KWBackground.h"

static const int kKWTimeLimitMaxSeconds = 1 * 60;

static const int kKWTimeLimitLevelCost  = 5;

@implementation KWLevel {
    
    KWBackground* background;
    
    NSMutableArray* baskets;
    NSMutableArray* kittens;
    NSMutableArray* toys;
    int level;
    
    NSUInteger timelimit;
    
    NSDate* start;

}

@synthesize level, bounds, timelimit;

- (NSArray*) objects {
    
    NSMutableArray* objects = [[NSMutableArray alloc] initWithCapacity:1 + baskets.count + kittens.count + toys.count];

    [objects addObject:background];
    [objects addObjectsFromArray:baskets];
    [objects addObjectsFromArray:kittens];
    [objects addObjectsFromArray:toys];
    
    return objects;
    
}

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
        
        background = [[KWBackground alloc] initWithLevel:self andFrame:bounds];

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
    return timelimit - (start ? [[NSDate date] timeIntervalSinceDate:start] : 0);
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
    
    [self.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
        if ([o tick:dt]) {
            [o setNeedsDisplay];
        }
    }];
            
}

- (void) free:(NSArray*)kits {
    [kits enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
        kitten.captured = NO;
        [kittens addObject:kitten];
    }];
}
 
- (void) drop:(KWObject*)object {
    if ([object isKindOfClass:[KWKitten class]]) {
        KWKitten* kitten = (KWKitten*)object;
        [baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *bstop) {
            if (CGRectContainsPoint(basket.frame, kitten.position)) {
                [kittens removeObject:kitten];
                [basket addKitten:kitten];
                kitten.captured = YES;
                *bstop = YES;
            }
        }];
    }
}

- (NSArray*) touched:(CGPoint)point {
    return [self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KWObject* o, NSDictionary *bindings) {
        float feather = -10.0f;
        return o.touchable && CGRectContainsPoint(CGRectInset(o.frame, feather, feather), point);
    }]];
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
