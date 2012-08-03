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
#import "KWToy.h"
#import "KWMouse.h"
#import "KWYarn.h"
#import "CALayer+KWMsg.h"

static const int KWTimeLimitMaxSeconds = 2 * 60;

static const int KWTimeLimitLevelCost  = 5;

@implementation KWLevel {
        
    int level;
    NSUInteger timelimit;
    NSDate* start;
    
    CATextLayer* background;

    NSMutableArray* objects;
}

@synthesize level, timelimit;
@dynamic bias;

+ (BOOL) needsDisplayForKey:(NSString *)key {
    static NSArray* keys;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ keys = @[@"bias"]; });
    return [keys containsObject:key] || [super needsDisplayForKey:key];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"level:%d limit:%d/%ds objects:%d",
            level, (int)[[NSDate date] timeIntervalSinceDate:start], timelimit,
            objects.count];
}

- (NSArray*) objects { return [objects copy]; }
- (NSArray*) kittens {
    return [self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KWObject* obj, NSDictionary *bindings) {
        return [obj isKindOfClass:[KWKitten class]];
    }]];
}
- (NSArray*) baskets {
    return [self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KWObject* obj, NSDictionary *bindings) {
        return [obj isKindOfClass:[KWBasket class]];
    }]];
}

- (id) initLevel:(int)lvl {
    if (self = [self init]) {
        self.needsDisplayOnBoundsChange = YES;
        self.fillColor = nil;
        self.strokeColor = [UIColor colorWithRed:0.7f green:0.4f blue:0.4f alpha:0.3f].CGColor;
        self.lineDashPattern = @[@5, @15];
        self.lineDashPhase = 0;
        self.lineWidth = 1.0f;
        self.frame = [UIScreen mainScreen].bounds;
        
        //xxx clean this up
        background = [[CATextLayer alloc] init];
        UIFont* bold = [UIFont boldSystemFontOfSize:38.0f];
        background.alignmentMode = @"center";
        background.font = (__bridge CFTypeRef)(bold.fontName);
        background.fontSize = 38.0f;
        CGSize size = [@"Level 99 (000 s)" sizeWithFont:bold];
        background.bounds = CGRectMake(0, 0, size.width, size.height);
        background.position = self.position;
        background.transform = CATransform3DMakeRotation(-M_PI_4, 0, 0, 1.0f);

        [self addSublayer:background];
                
        level = lvl;
        timelimit = KWTimeLimitMaxSeconds - (KWTimeLimitLevelCost * level);

        objects = [[NSMutableArray alloc] init];
        
        [objects addObject:[[KWBasket alloc] initWithLevel:self]];
        for (int i = 0; i < level / 3; i++) {
            [objects addObject:[[KWBasket alloc] initWithLevel:self]];
        }
        
        for (int i = 0; i < level * (KWRandom(KWKittensPerLevel) + KWKittensPerLevel); i++) {
            [objects addObject:[[KWKitten alloc] initWithLevel:self]];
        }
        
        [objects addObject:[[KWYarn alloc] initWithLevel:self]];
        
        [objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
            while (!CGRectContainsRect(self.bounds, obj.frame) || ![self vacant:obj.frame excluding:obj]) {
                obj.position = CGPointMake(arc4random_uniform(self.bounds.size.width), arc4random_uniform(self.bounds.size.height));
            }
            [self addSublayer:obj];
        }];
                
    }
    return self;
}

- (void) addMouse {
    KWMouse* mouse = [[KWMouse alloc] initWithLevel:self];
    
    while (!CGRectContainsRect(self.bounds, mouse.frame) || ![self vacant:mouse.frame excluding:mouse]) {
        mouse.position = CGPointMake(arc4random_uniform(self.bounds.size.width), arc4random_uniform(self.bounds.size.height));
    }

    [self addSublayer:mouse];
    [objects addObject:mouse];
}

- (NSTimeInterval) remaining {
    return timelimit - (start ? [[NSDate date] timeIntervalSinceDate:start] : 0);
}

- (BOOL) timeout { return self.remaining <= 0; }

- (BOOL) complete {
    __block BOOL uncaptured = NO;
    [self.objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
        [self.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
            NSString* name = [NSStringFromClass([o class]) substringFromIndex:2];
            if ([@[@"Yarn", @"Basket"] containsObject:name]) {
                [self hover:name over:o.position];                
            }
        }];
        
        return;
    }
        
    [self.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
        if ([o tick:dt]) { [o setNeedsDisplay]; }
    }];
    
    if (KWRandomPercent < KWMouseChance * self.kittens.count) {
        [self addMouse];
    }
        
    double remaining = self.remaining;
    float remain = (0.8f * (1.0f - (remaining / self.timelimit)));
    
    background.foregroundColor = [UIColor colorWithRed:0.7f green:0.3f blue:0.3f alpha:0.2f + remain].CGColor;

    background.string = [NSString stringWithFormat:@"Level %d (%d s)", self.level, (int)remaining];
}
 
- (void) capture:(KWObject*)object {
    if ([object isKindOfClass:[KWKitten class]]) {
        KWKitten* kitten = (KWKitten*)object;
        [self.baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *bstop) {
            if (CGRectContainsPoint(basket.frame, kitten.position)) {
                kitten.basket = basket;
                kitten.touchable = NO;
                [self flash:@"Kitten Captured!" at:kitten.position];
                *bstop = YES;
            }
        }];
    } else if (object.catchable) {
        [object removeFromSuperlayer];
        [objects removeObject:object];
    }
}

- (NSArray*) touched:(CGPoint)point {
    return [self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KWObject* o, NSDictionary *bindings) {
        float feather = -10.0f;
        return o.touchable && CGRectContainsPoint(CGRectInset(o.frame, feather, feather), point);
    }]];
}

//xxx rethink this?
- (BOOL) vacant:(CGRect)rect excluding:(KWObject*)obj {
    
    __block BOOL vacant = YES;
    
    [self.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
        if (o != obj && CGRectIntersectsRect(rect, o.frame)) {
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
    
    [self.objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
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

@end
