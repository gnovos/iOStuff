//
//  KWObject.m
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWObject.h"
#import "KWLevel.h"

@implementation KWObject

@synthesize held, level, heading;

@dynamic velocity;

- (id) initWithLevel:(KWLevel*)lvl andSize:(CGSize)size {
    if (self = [super init]) {
        self.needsDisplayOnBoundsChange = YES;
        level = lvl;
        CGRect rect = CGRectZero;
        while (CGRectIsEmpty(rect) || !CGRectContainsRect(level.bounds, rect) || ![level vacant:rect.origin excluding:self]) {
            rect.size = size;
            rect.origin = [self randomPointIn:level.bounds];
        }
        self.frame = rect;
        self.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
        heading = kKWRandomHeading;
    }
    return self;
}

+ (BOOL) needsDisplayForKey:(NSString *)key {
    if ([@"velocity" isEqualToString:key]) {
        return YES;
    }
    dlobj(key);
    return [super needsDisplayForKey:key];
}

- (CGPoint) randomPointIn:(CGRect)rect {
    return CGPointMake(arc4random_uniform(rect.size.width), arc4random_uniform(rect.size.height));
}

- (BOOL) moving   { return !held && self.velocity > KWObjectVelocityMotionless; }

- (void) tick:(CGFloat)dt {
//    dlog(@"tick:%f %@", dt, self);
    
    while (heading < 0 || heading > kKWAngle360Degrees) {
        heading += heading < 0 ? kKWAngle360Degrees : -kKWAngle360Degrees;
    }
    
    CGFloat dir = degreesToRadians(heading);
    
    self.transform = CATransform3DMakeRotation(dir, 0, 0, 1.0f);

    if (self.moving) {
        
        CGFloat dm = self.velocity * dt;
        
        CGPoint p = self.position;
        
        p.x += dm * cosf(dir);
        p.y += dm * sinf(dir);
        
        if (CGRectContainsPoint(level.bounds, p) && [level vacant:p excluding:self]) {
            self.position = p;
        } else {
            if (p.x < 0) {
                p.x = 1.0f;
            }
            if (p.y < 0) {
                p.y = 1.0f;
            }
            if (p.x > CGRectGetMaxX(level.bounds)){
                p.x = CGRectGetMaxX(level.bounds) - 1.0f;
            }
            if (p.y > CGRectGetMaxY(level.bounds)){
                p.y = CGRectGetMaxY(level.bounds) - 1.0f;
            }
            heading += kKWRandomHeading;
        }

    }
}

- (CGFloat) directionOf:(KWObject*)other {
    CGPoint a = other.position;
    CGPoint b = self.position;
    
    CGFloat dx = a.x - b.x;
    CGFloat dy = a.y - b.y;
        
    CGFloat dir = dx ? tan(dy / dx) : dy < 0 ? kKWAngle270Degrees : kKWAngle90Degrees;
    return dir;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ loc:(%d,%d) v:%d",
            self.class,
            (int)self.position.x, (int)self.position.y, self.velocity];
}

@end
