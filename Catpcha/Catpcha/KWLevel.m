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

static const int kKWTimeLimitMaxSeconds = 1 * 60;

static const int kKWTimeLimitLevelCost  = 5;

@implementation KWLevel {
        
    int level;
    NSUInteger timelimit;
    NSDate* start;
    
    CATextLayer* text;

    NSMutableArray* objects;
}

@synthesize level, timelimit, bias;

- (NSString*) description {
    return [NSString stringWithFormat:@"level:%d limit:%d/%ds objects:%d",
            level, (int)[[NSDate date] timeIntervalSinceDate:start], timelimit,
            objects.count];
}

- (NSArray*) objects { return [objects copy]; }

- (id) initLevel:(int)lvl {
    if (self = [self init]) {
        self.needsDisplayOnBoundsChange = YES;
        self.strokeColor = [UIColor colorWithRed:0.7f green:0.4f blue:0.4f alpha:0.3f].CGColor;
        self.lineDashPattern = @[@5, @15];
        self.lineDashPhase = 0;
        self.lineWidth = 1.0f;
        self.frame = [UIScreen mainScreen].bounds;
        
        //xxx clean this up
        text = [[CATextLayer alloc] init];
        UIFont* bold = [UIFont boldSystemFontOfSize:38.0f];
        text.alignmentMode = @"center";
        text.font = (__bridge CFTypeRef)(bold.fontName);
        text.fontSize = 38.0f;
        CGSize size = [@"Level 99 (000 s)" sizeWithFont:bold];
        text.bounds = CGRectMake(0, 0, size.width, size.height);
        text.position = self.position;
        text.transform = CATransform3DMakeRotation(-M_PI_4, 0, 0, 1.0f);

        [self addSublayer:text];
                
        level = lvl;
        timelimit = kKWTimeLimitMaxSeconds - (kKWTimeLimitLevelCost * level);

        objects = [[NSMutableArray alloc] init];
        
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
        return;
    }
        
    UIBezierPath* path = [[UIBezierPath alloc] init];
    
    [self.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
        if ([o tick:dt]) { [o setNeedsDisplay]; }
        
        if ([o isKindOfClass:[KWKitten class]]) {            
            [[self sight:o] enumerateObjectsUsingBlock:^(KWObject* kk, NSUInteger idx, BOOL *lstop) {
                [path moveToPoint:o.position];
                [path addLineToPoint:kk.position];
                [path closePath];
            }];
        }
    }];
    
    self.path = path.CGPath;
    
    double remaining = self.remaining;
    float remain = (0.8f * (1.0f - (remaining / self.timelimit)));
    
    text.foregroundColor = [UIColor colorWithRed:0.7f green:0.3f blue:0.3f alpha:0.2f + remain].CGColor;

    text.string = [NSString stringWithFormat:@"Level %d (%d s)", self.level, (int)remaining];
    
    //xxx rethink how often this is required
    [self setNeedsDisplay];
}

- (void) free:(KWKitten*)kitten {
    kitten.captured = NO;
    [objects addObject:kitten];
}
 
- (void) drop:(KWObject*)object {
    if ([object isKindOfClass:[KWKitten class]]) {
        KWKitten* kitten = (KWKitten*)object;
        [self.objects enumerateObjectsUsingBlock:^(KWBasket* basket, NSUInteger idx, BOOL *bstop) {
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
    return [self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KWObject* o, NSDictionary *bindings) {
        float feather = -10.0f;
        return o.touchable && CGRectContainsPoint(CGRectInset(o.frame, feather, feather), point);
    }]];
}

- (BOOL) vacant:(CGPoint)p excluding:(KWObject*)obj {
    
    __block BOOL vacant = YES;
    
    [self.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
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
