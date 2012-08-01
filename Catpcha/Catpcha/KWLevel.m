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
#import "KWLine.h"

static const int kKWTimeLimitMaxSeconds = 1 * 60;

static const int kKWTimeLimitLevelCost  = 5;

@implementation KWLevel {
        
    NSMutableArray* objects;
    
    int level;
    
    NSUInteger timelimit;
    
    NSDate* start;
    
    NSMutableArray* sight;


}

@synthesize level, timelimit;

- (NSString*) description {
    return [NSString stringWithFormat:@"level:%d limit:%d/%ds objects:%d",
            level, (int)[[NSDate date] timeIntervalSinceDate:start], timelimit,
            objects.count];
}

- (NSArray*) objects { return [objects copy]; }

- (id) initLevel:(int)lvl {
    if (self = [self init]) {
        self.needsDisplayOnBoundsChange = YES;
                
        level = lvl;
        timelimit = kKWTimeLimitMaxSeconds - (kKWTimeLimitLevelCost * level);

        self.frame = [UIScreen mainScreen].bounds;
        objects = [[NSMutableArray alloc] init];
        sight = [[NSMutableArray alloc] init];
        
        [objects addObject:[[KWBasket alloc] initWithLevel:self]];
        for (int i = 0; i < level / 3; i++) {
            [objects addObject:[[KWBasket alloc] initWithLevel:self]];
        }
        
        for (int i = 0; i < level * (kKWRandom(kKWKittensPerLevel) + kKWKittensPerLevel); i++) {
            [objects addObject:[[KWKitten alloc] initWithLevel:self]];
        }
        
        [objects addObject:[[KWMouse alloc] initWithLevel:self]];
        
        [objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
            while (!CGRectContainsRect(self.bounds, obj.frame) || ![self vacant:obj.frame.origin excluding:obj]) {
                obj.position = CGPointMake(arc4random_uniform(self.bounds.size.width), arc4random_uniform(self.bounds.size.height));
            }
            [self addSublayer:obj];
        }];
        
        
    }
    return self;
}

- (NSTimeInterval) remaining {
    return timelimit - (start ? [[NSDate date] timeIntervalSinceDate:start] : 0);
}

- (BOOL) timeout { return self.remaining <= 0; }

- (BOOL) complete {
    __block BOOL uncaptured = NO;
    [[objects copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KWKitten class]] && !((KWKitten*)obj).captured) {
            uncaptured = YES;
            *stop = YES;
        }
    }];
    
    return !uncaptured || [self timeout];
}

- (void) tick:(CGFloat)dt {    
    if (start == nil) {
        start = [NSDate date];
        return;
    }
        
    [sight removeAllObjects];
    
    [[objects copy] enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
        if ([o tick:dt]) { [o setNeedsDisplay]; }
        
        if ([o isKindOfClass:[KWKitten class]]) {            
            [[self sight:o] enumerateObjectsUsingBlock:^(KWObject* kk, NSUInteger idx, BOOL *lstop) {
                KWLine* line = [[KWLine alloc] init];
                line.start = o.position;
                line.end = kk.position;
                [sight addObject:line];
            }];
        }
    }];
    [self setNeedsDisplay];
}

- (void) free:(KWKitten*)kitten {
    kitten.captured = NO;
    [objects addObject:kitten];
}
 
- (void) drop:(KWObject*)object {
    if ([object isKindOfClass:[KWKitten class]]) {
        KWKitten* kitten = (KWKitten*)object;
        [[objects copy] enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *bstop) {
            if (CGRectContainsPoint(basket.frame, kitten.position)) {
                [objects removeObject:kitten];
                [basket addKitten:kitten];
                kitten.captured = YES;
                *bstop = YES;
            }
        }];
    }
}

- (NSArray*) touched:(CGPoint)point {
    return [[objects copy] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KWObject* o, NSDictionary *bindings) {
        float feather = -10.0f;
        return o.touchable && CGRectContainsPoint(CGRectInset(o.frame, feather, feather), point);
    }]];
}

- (BOOL) vacant:(CGPoint)p excluding:(KWObject*)obj {
    
    __block BOOL vacant = YES;
    
    [[objects copy] enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
        if (o != obj && CGRectContainsPoint(o.frame, p)) {
            vacant = NO;
            *stop = YES;
        }
    }];
    
    return vacant;
}

- (NSArray*) sight:(KWObject*)seer {
    
    NSMutableArray* visible = [[NSMutableArray alloc] init];
    
    CGFloat rads = degreesToRadians(seer.heading);
    
    CGPoint p = seer.position;
    
    [[objects copy] enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
        if (obj != seer) {
            CGPoint q = obj.position;
                        
            CGFloat dist = p.x - q.x;
            CGFloat dir = cosf(rads);
            BOOL match = (dir < 0 && dist > 0) || (dir > 0 && dist < 0);
            
            if (match) {
                CGFloat m = tan(rads) * dist;
                q.y = p.y - m;
                CGRect size = obj.frame;
                if (size.size.width < seer.frame.size.width || size.size.height < seer.frame.size.height) {
                    size.size = seer.frame.size;
                }
                
                //xxx look into making this a constant or less constant?
                CGRect view = CGRectInset(size, -10.0f, -10.0f);
                
                if (CGRectContainsPoint(view, q)) {
                    [visible addObject:obj];
                }            
            }
        }
    }];
    
    return visible;

}

- (void) drawInContext:(CGContextRef)ctx {
    KWGFX* gfx = [[KWGFX alloc] initWithContext:ctx];
    
    double remaining = self.remaining;
    float remain = (0.8f * (1.0f - (remaining / self.timelimit)));
    
    UIColor* fill = [UIColor colorWithRed:0.7f green:0.3f blue:0.3f alpha:0.2f + remain];
    if (remaining > 0) {
        NSString* text = [NSString stringWithFormat:@"Level %d (%d s)", self.level, (int)remaining];
        [[[[[[[gfx stroke:[UIColor colorWithRed:0.5f green:0.5f blue:0.7f alpha:0.3f]] fill:fill] angle:-45.0f] mode:kCGTextFillStroke]
           font:@"Helvetica Bold" size:38.0f] x:80.0f y:345.0f] text:text];
    }
    
    [[gfx stroke:[UIColor colorWithRed:0.1f green:0.5f blue:0.3f alpha:0.6f]] dash:10.0f off:7.0f];
    [sight enumerateObjectsUsingBlock:^(KWLine* line, NSUInteger idx, BOOL *stop) {
        [gfx line:line.start to:line.end];
    }];
    
}


@end
