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

@synthesize heading, rotation, velocity, held, level, layer;

- (id) initWithLevel:(KWLevel*)lvl andSize:(CGSize)size {
    if (self = [super init]) {
        level = lvl;
        layer = [CALayer layer];
        CGRect bounds = layer.bounds;
        while (CGRectIsEmpty(bounds) || !CGRectContainsRect(level.bounds, bounds) || ![level vacant:bounds excluding:self]) {
            bounds.size = size;
            bounds.origin = [self randomPointIn:level.bounds];
        }
        layer.bounds = bounds;
    }
    return self;
}

- (CGPoint) randomPointIn:(CGRect)rect {
    return CGPointMake(arc4random_uniform(rect.size.width), arc4random_uniform(rect.size.height));
}

- (CGPoint) location { return layer.bounds.origin; }
- (CGSize)  size     { return layer.bounds.size;   }
- (CGPoint) center   { return KWCGRectCenter(layer.bounds); }

- (BOOL)    moving   { return !held && velocity > KWObjectVelocityMotionless; }

- (void) normalizeRotation {
    while (rotation < 0 || rotation > kKWAngle360Degrees) {
        rotation += rotation < 0 ? kKWAngle360Degrees : -kKWAngle360Degrees;
    }    
    while (heading < 0 || heading > kKWAngle360Degrees) {
        heading += heading < 0 ? kKWAngle360Degrees : -kKWAngle360Degrees;
    }
}

- (void) tick:(CGFloat)dt {
//xxx    dlog(@"tick:%f %@", dt, self);
    
    [self normalizeRotation];
        
    if (rotation != heading) {
        CGFloat rx = heading - rotation;        
        rotation += rx / 2.0;
    }
    
    if (self.moving) {
        //xxx introduce accelerometer bias
        CGPoint d = CGPointMake(sin(rotation / kKWAngle180Degrees * M_PI) * (dt * velocity),
                                sin((rotation + kKWAngle90Degrees) / kKWAngle180Degrees * M_PI) * (dt * velocity));
        
        CGRect loc = CGRectMake(layer.bounds.origin.x + d.x, layer.bounds.origin.y + d.y, layer.bounds.size.width, layer.bounds.size.height);
        
        if ([level vacant:loc excluding:self] && CGRectContainsRect(level.bounds, loc)) {
            layer.bounds = loc;
        } else {
            heading += kKWAngle15Degrees;
        }        
    }
    
}

- (CGFloat) directionOf:(KWObject*)other {
    CGPoint a = other.center;
    CGPoint b = self.center;
    
    CGFloat dx = a.x - b.x;
    CGFloat dy = a.y - b.y;
        
    CGFloat dir = dx ? tan(dy / dx) : dy < 0 ? kKWAngle270Degrees : kKWAngle90Degrees;
    return dir;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ loc:(%d,%d) rot:%d/%d v:%d",
            self.class,
            (int)layer.bounds.origin.x, (int)layer.bounds.origin.y,
            (int)heading, (int)rotation, velocity];
}



@end
