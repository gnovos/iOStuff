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

}

@synthesize level, timelimit, bias;

- (NSString*) description {
    return [NSString stringWithFormat:@"level:%d limit:%d/%ds objects:%d",
            level, (int)[[NSDate date] timeIntervalSinceDate:start], timelimit,
            self.shapes.count];
}

- (NSArray*) objects { return [self.shapes copy]; }
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
- (NSArray*) mice {
    return [self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KWObject* obj, NSDictionary *bindings) {
        return [obj isKindOfClass:[KWMouse class]];
    }]];
}

//xxxz
//- (void) setFrame:(CGRect)frame {
//    [super setFrame:frame];
//    [self reset];
//}

- (void) reset {
//xxxz    
//    [[self sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//    
//    UIFont* bold = [UIFont boldSystemFontOfSize:38.0f * 3];
//    background = [self textlayer:@"Level 00 (000 s)" font:bold];
//    background.foregroundColor = [UIColor clearColor].CGColor;
//    background.position = self.position;
//    background.transform = CATransform3DMakeRotation(-M_PI_4, 0, 0, 1.0f);
//    
//    [self addSublayer:background];
//    
//    CAShapeLayer* fence = [CAShapeLayer layer];
//    fence.frame = self.frame;
//    fence.fillColor = nil;
//    fence.strokeColor = [UIColor colorWithRed:0.5f green:0.3f blue:0.1f alpha:0.7f].CGColor;
//    fence.lineWidth = 3.0f;
//    fence.lineDashPattern = @[@100.0f, @50.0f];
//    fence.path = [UIBezierPath bezierPathWithRoundedRect:self.frame cornerRadius:40.0f].CGPath;
//    
//    [self addSublayer:fence];
//    
//    self.shadowRadius = 20.0f;
//    self.shadowOpacity = 0.65f;
//    self.shouldRasterize = YES;
//    self.shadowOffset = CGSizeMake(0, 0);
//    self.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, -10.0f, -10.0f) cornerRadius:40.0f].CGPath;
//    
//    [objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
//        [self addSublayer:obj];
//    }];   
}

- (void) populate {
    
    [self removeAll];
    
    NSMutableArray* objects = [[NSMutableArray alloc] init];
    
    [objects addObject:[[KWBasket alloc] initWithLevel:self]];
    
    int kitcount = MAX(level, KWRandom(KWKittensPerLevel * level));
    
    for (int i = 0; i < kitcount; i++) {
        [objects addObject:[[KWKitten alloc] initWithLevel:self]];
    }

    if (level % 3 == 0) {
        [objects addObject:[[KWYarn alloc] initWithLevel:self]];        
    }

    [objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
        [self yield:obj];
    }];
    
    [self reset];
}

- (void) yield:(KWObject*)obj {
    obj.moment.position = KWRandomPosition(obj.size, self.bounds);
    while ([self collision:obj.bounds]) {
        obj.moment.position = KWRandomPosition(obj.size, self.bounds);
    }
    [self add:obj];    
}

- (BOOL) collision:(CGRect)rect {
    __block BOOL collision = NO;
    [self.objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
        if (CGRectIntersectsRect(obj.bounds, rect)) {
            collision = YES;
            *stop = YES;
        }
    }];
    return collision;
}

- (id) initLevel:(int)lvl withSize:(CGSize)size {
    if (self = [super initWithTexture:nil andSize:size]) {
        self.moment.color = GLKVector4Make(KWRandomPercent, KWRandomPercent, KWRandomPercent, 1.0f);

        timelimit = KWTimeLimitMaxSeconds - (KWTimeLimitLevelCost * level);
        
//        id pink = (id)[UIColor colorWithRed:0.9f green:0.5f blue:0.7f alpha:0.7f].CGColor;
//        id pg = (id)[UIColor colorWithRed:0.5f green:0.9f blue:0.4f alpha:0.7f].CGColor;
//        id pb = (id)[UIColor colorWithRed:0.5f green:0.4f blue:0.9f alpha:0.7f].CGColor;
//        id pr = (id)[UIColor colorWithRed:0.9f green:0.2f blue:0.1f alpha:0.7f].CGColor;
//        id pq = (id)[UIColor colorWithRed:KWRandomPercent green:KWRandomPercent blue:KWRandomPercent alpha:0.7f].CGColor;
//        id white = (id)[UIColor colorWithRed:0.9f green:0.95f blue:0.95f alpha:0.7f].CGColor;

//xxxz
//        self.colors = @[pink, white, pg, pq, pink, white, pb, pr, pq];
//        self.locations = @[@0.0f, @0.3f, @0.4f, @0.5f, @0.6f, @0.7f, @0.9f, @0.95f, @1.0f];
//        self.startPoint = CGPointMake(KWRandomPercent, KWRandomPercent);
//        self.endPoint = CGPointMake(KWRandomPercent, KWRandomPercent);
//        
//        self.cornerRadius = 40.0f;
        
        level = lvl;

    }
    return self;
}

- (void) addMouse {
    if (KWRandomPercent < KWMouseChance * self.kittens.count && self.mice.count <= self.kittens.count/ 2.0f) {
        KWMouse* mouse = [[KWMouse alloc] initWithLevel:self];
//xxxz        
//        while (!CGRectContainsRect(self.bounds, mouse.frame) || ![self vacant:mouse.frame excluding:mouse]) {
//            mouse.position = CGPointMake(arc4random_uniform(self.bounds.size.width), arc4random_uniform(self.bounds.size.height));
//        }
//        
//        [self addSublayer:mouse];
//        [objects addObject:mouse];
    }
}

- (NSTimeInterval) remaining {
    return timelimit - (start ? [[NSDate date] timeIntervalSinceDate:start] : 0);
}

- (BOOL) timeout { return self.remaining <= 0; }

- (BOOL) solved {
    __block BOOL uncaptured = NO;
    [self.objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KWKitten class]] && !((KWKitten*)obj).captured) {
            uncaptured = YES;
            *stop = YES;
        }
    }];
    return !uncaptured;
}

- (BOOL) complete {
    return self.solved || self.timeout;
}

- (void) tick:(CGFloat)dt {    
    if (start == nil) {
        start = [NSDate date];
        [self.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
            NSString* name = [NSStringFromClass([o class]) substringFromIndex:2];
            if ([@[@"Yarn", @"Basket"] containsObject:name]) {
//xxxz                [self hover:name over:o.position];                
            }
        }];
        
        return;
    }
        
    [self.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
//xxxz        if ([o tick:dt]) { [o setNeedsDisplay]; }
    }];
    
    [self addMouse];
        
    double remaining = self.remaining;
    CGFloat danger = (0.8f * (1.0f - (remaining / self.timelimit)));
    
//xxxz    background.foregroundColor = [UIColor colorWithRed:0.2f + danger green:0.9f blue:0.9f alpha:0.9f].CGColor;
//xxxz    background.string = [NSString stringWithFormat:@"Level %d (%d s)", self.level, (int)remaining];
}
 
- (void) capture:(KWObject*)object {
//xxxz
//    if ([object isKindOfClass:[KWKitten class]]) {
//        KWKitten* kitten = (KWKitten*)object;
//        [self.baskets enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *bstop) {
//            if (CGRectContainsPoint(basket.frame, kitten.position)) {
//                kitten.basket = basket;
//                kitten.touchable = NO;
//                [self flash:@"Kitten Captured!" at:kitten.position];
//                *bstop = YES;
//            }
//        }];
//    } else if (object.catchable) {
//        [object removeFromSuperlayer];
//        [objects removeObject:object];
//    }
}

- (NSArray*) touched:(CGPoint)point {
//xxxz    
//    return [self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KWObject* o, NSDictionary *bindings) {
//        return o.touchable && CGRectContainsPoint(CGRectInset(o.frame, KWTouchFeather, KWTouchFeather), point);
//    }]];
}

//xxx rethink how to do this more efficiently?
- (BOOL) vacant:(CGRect)rect excluding:(KWObject*)obj {
    
    __block BOOL vacant = YES;
    
    [self.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
//xxxz        
//        if (o != obj && CGRectIntersectsRect(rect, o.frame)) {
//            vacant = NO;
//            *stop = YES;
//        }
    }];
    
    return vacant;
}

- (NSArray*) sight:(KWObject*)seer {
    
    NSMutableArray* visible = [[NSMutableArray alloc] init];

//xxxz
//    CGFloat rads = degreesToRadians(seer.heading);
//    
//    CGPoint p = seer.position;
//    
//    [self.objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
//        if (obj != seer) {
//            CGPoint q = obj.position;
//                        
//            CGFloat dist = p.x - q.x;
//            CGFloat dir = cosf(rads);
//            BOOL match = (dir < 0 && dist > 0) || (dir > 0 && dist < 0);
//            
//            if (match) {
//                CGFloat m = tan(rads) * dist;
//                q.y = p.y - m;
//                CGRect size = obj.frame;
//                if (size.size.width < seer.frame.size.width || size.size.height < seer.frame.size.height) {
//                    size.size = seer.frame.size;
//                }
//                
//                CGRect view = CGRectInset(size, KWTouchFeather, KWTouchFeather);                
//                if (CGRectContainsPoint(view, q)) {
//                    [visible addObject:obj];
//                }            
//            }
//        }
//    }];
//    
    return visible;
}

@end
