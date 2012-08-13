//
//  KWObject.m
//  Catpcha
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWObject.h"
#import "KWLevel.h"
#import "NSObject+KW.h"

@implementation KWObject

@synthesize level, heading, touchable, catchable, allure;

@dynamic touch, velocity;

+ (BOOL) needsDisplayForKey:(NSString *)key {
    static NSArray* keys;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ keys = @[@"velocity", @"touch",@"capture"]; });
    return [keys containsObject:key] || [super needsDisplayForKey:key];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ loc:(%d,%d) v:%d",
            self.class, (int)self.position.x, (int)self.position.y, self.velocity];
}

- (id) initWithLevel:(KWLevel*)lvl andSize:(CGSize)size {
    if (self = [super init]) {
        static char oids = 0;
        self.oid = oids++;
                
        self.shouldRasterize = YES;
        self.lineWidth = 1.0f;
        self.fillColor = nil;
        touchable = NO;
        catchable = NO;
        allure = 0.0f;
        level = lvl;
        self.needsDisplayOnBoundsChange = YES;
        heading = KWRandomHeading;
        self.bounds = CGRectMake(0, 0, size.width, size.height);
        self.path = self.shape.CGPath;
        
        __weak KWObject* slf = self;
        
        [self observe:@"touch" with:^(NSDictionary *change) {
            id last = [change valueForKey:@"old"];
            id touch = [change valueForKey:@"new"];
            
            if (last == [NSNull null]) { last = nil; }
            if (touch == [NSNull null]) { touch = nil; }
            
            if (last == nil || touch != nil) {
                [slf grab];
            } else if (touch == nil) {
                [slf drop];
            }
        }];
        
        [self observe:@"position" with:^(NSDictionary *change) {
            if (slf.touch && [change valueForKey:@"old"]) {
                CGPoint loc = slf.position;
                CGPoint last = [[change valueForKey:@"old"] CGPointValue];
                CGFloat angle = [slf angle:last end:loc];
                slf.heading = angle;
            }
        }];
        
    }
    return self;
}

- (UIBezierPath*) shape { return nil; }

- (void) grab {}

- (void) drop {}

- (BOOL) moving   { return !self.touch && self.velocity > KWObjectVelocityMotionless; }

- (CGFloat) angle:(CGPoint)start end:(CGPoint)end {
    
    CGFloat dx = start.x - end.x;
    CGFloat dy = start.y - end.y;
    
    CGFloat slope = dx / dy;
    
    if (slope == INFINITY) {
        return KWAngle180Degrees;
    } else if (slope == -INFINITY) {
        return KWAngle0Degrees;
    }
        
    CGFloat angle = -radiansToDegrees(atanf(slope));
    
    angle += (start.y > end.y) ? -90 : 90;
    
    return angle;

}

- (CGFloat) direction:(KWObject*)other {
    return [self angle:self.position end:other.position];
}

- (BOOL) tick:(CGFloat)dt {
    if (self.moving) {
        [level.objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
            if (obj != self && CGRectContainsPoint(obj.frame, self.position)) {
                self.heading = [self direction:obj] - 180.0f;
                *stop = YES;
            }
        }];        
        
        while (heading < 0 || heading > KWAngle360Degrees) {
            heading += heading < 0 ? KWAngle360Degrees : -KWAngle360Degrees;
        }
        
        CGFloat dir = degreesToRadians(heading);
        
        if (CATransform3DIsIdentity(self.transform)) {
            self.transform = CATransform3DMakeRotation(dir, 0, 0, 1.0f);
        } else {
            self.transform = CATransform3DRotate(self.transform, dir, 0, 0, 1.0f);
        }
        
        CGFloat dm = self.velocity * dt;
        
        CGPoint p = self.position;
        
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
            heading += KWRandomHeading;
        }
        
        self.position = p;
        
    }
        
    return NO;
}

@end
