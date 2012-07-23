//
//  KWMouse.m
//  KittenWrangler
//
//  Created by Mason on 7/22/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWMouse.h"

@implementation KWMouse

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:kKWDefaultMouseSize]) {
        self.velocity = KWObjectVelocitySuperFast;
    }
    return self;
}

- (void) tick:(CGFloat)dt {
    CGFloat tilt = kKWRandom(kKWAngle23Degrees);
    if ((int)tilt % 2 == 0) {
        tilt *= -1;
    }
    self.heading += tilt;
    [super tick:dt];    
}

- (void) drawInContext:(CGContextRef)ctx {
    KWGFX* gfx = [[KWGFX alloc] initWithContext:ctx];
    
    CGFloat inner = 1.0f;
    
    CGRect b = CGRectInset(self.bounds, inner, inner);
    
//    [[[[[gfx stroke:UIColor.darkGrayColor]
//        fill:UIColor.darkGrayColor]
//       line:CGPointMake(0, b.origin.y / 2.0f) to:CGPointMake(0, b.size.height)]
//      to:CGPointMake(b.size.width, b.size.height)]
//     to:CGPointMake(0, b.origin.y / 2.0f)];
    
    [[gfx fill:UIColor.darkGrayColor] felipse:b];
        
}


@end
