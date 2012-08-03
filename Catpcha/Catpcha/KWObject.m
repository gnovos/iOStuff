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

@synthesize level, heading, touchable, catchable, allure;

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
        catchable = NO;
        allure = 0.0f;
        level = lvl;
        self.needsDisplayOnBoundsChange = YES;
        heading = KWRandomHeading;
        self.bounds = CGRectMake(0, 0, size.width, size.height);
        self.path = self.shape.CGPath;
        [self addObserver:self forKeyPath:@"touch" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
        [self addObserver:self forKeyPath:@"position" options:(NSKeyValueObservingOptionOld) context:NULL];
    }
    return self;
}

- (void) dealloc {
    [self removeObserver:self forKeyPath:@"position"];
    [self removeObserver:self forKeyPath:@"touch"];
}

- (UIBezierPath*) shape { return nil; }

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if ([@"position" isEqualToString:keyPath] && self.touch) {
        CGPoint loc = self.position;
        CGPoint last = [[change valueForKey:@"old"] CGPointValue];
        CGFloat angle = [self angle:last end:loc];
        self.heading = angle;        
    } else if ([@"touch" isEqualToString:keyPath]) {
        id last = [change valueForKey:@"old"];
        id touch = [change valueForKey:@"new"];
        
        if (last == [NSNull null]) { last = nil; }
        if (touch == [NSNull null]) { touch = nil; }
        
        if (last == nil || touch != nil) {
            [self grab];
        } else if (touch == nil) {            
            [self drop];
        }
    }
}

- (void) grab {}

- (void) drop {}

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

- (CGFloat) angle:(CGPoint)start end:(CGPoint)end {
    
    float dx = start.x - end.x;
    float dy = start.y - end.y;
    
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
            heading += KWRandomHeading;
        }

        //xxx what is ths?
//        CGRect rect = self.frame;
//        rect.origin = CGPointMake(p.x - self.frame.size.width / 2.0f, p.y - self.frame.size.height / 2.0f);
        
        self.position = p;
        
    }
        
    return NO;
}

@end
