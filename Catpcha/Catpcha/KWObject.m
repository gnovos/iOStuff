//
//  KWObject.m
//  Catpcha
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWObject.h"
#import "KWLevel.h"

@implementation KWObject

@synthesize level, heading, touchable, allure;

@dynamic touch, velocity;

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ loc:(%d,%d) v:%d",
            self.class, (int)self.position.x, (int)self.position.y, self.velocity];
}

- (id) initWithLevel:(KWLevel*)lvl andSize:(CGSize)size {
    if (self = [super init]) {
        self.lineWidth = 1.0f;
        self.fillColor = nil;
        touchable = NO;
        allure = 0.0f;
        level = lvl;
        self.needsDisplayOnBoundsChange = YES;
        heading = kKWRandomHeading;
        self.bounds = CGRectMake(0, 0, size.width, size.height);
        self.shadowColor = [UIColor blackColor].CGColor;
        self.shadowOffset = CGSizeMake(2.0, 2.0);
        self.shadowRadius = 3.0f;
        self.shadowOpacity = 0.7f;
    }
    return self;
}

+ (BOOL) needsDisplayForKey:(NSString *)key {
    
    static NSSet* keys;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        keys = [NSSet setWithObjects:
                @"velocity",
                @"touch",
                @"capture",
                nil];
    });
    
    return [keys containsObject:key] || [super needsDisplayForKey:key];
}

- (BOOL) moving   { return !self.touch && self.velocity > KWObjectVelocityMotionless; }

- (CGFloat) direction:(KWObject*)other {
    CGPoint p = self.position;
    CGPoint q = other.position;
    
    CGFloat slope = (p.x - q.x) / (p.y - q.y);
    
    CGFloat angle = -radiansToDegrees(atanf(slope));
    
    angle += (p.y > q.y) ? -90 : 90;

    return angle;
}

- (BOOL) tick:(CGFloat)dt {
    if (self.moving) {
        [level.objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
            if (obj != self && CGRectContainsPoint(obj.frame, self.position)) {
                self.heading = [self direction:obj] - 180.0f;
                *stop = YES;
            }
        }];        
        
        while (heading < 0 || heading > kKWAngle360Degrees) {
            heading += heading < 0 ? kKWAngle360Degrees : -kKWAngle360Degrees;
        }
        
        CGFloat dir = degreesToRadians(heading);
        
        self.transform = CATransform3DMakeRotation(dir, 0, 0, 1.0f);
    
        CGFloat dm = self.velocity * dt;
        
        __block CGPoint p = self.position;
        
        CGPoint bias = level.bias;
        
        p.x += (dm * cosf(dir)) + (bias.x * dt);
        p.y += dm * sinf(dir);
                        
        if (!CGRectContainsPoint(level.bounds, p)) {
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

        CGRect rect = self.frame;
        rect.origin = CGPointMake(p.x - self.frame.size.width / 2.0f, p.y - self.frame.size.height / 2.0f);
        
        self.position = p;
        
    }
        
    return NO;
}

@end
