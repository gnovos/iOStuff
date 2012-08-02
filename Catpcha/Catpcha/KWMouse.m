//
//  KWMouse.m
//  Catpcha
//
//  Created by Mason on 7/22/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWMouse.h"

@implementation KWMouse

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:kKWDefaultMouseSize]) {
        UIBezierPath* shape = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
        self.path = shape.CGPath;
        self.fillColor = [UIColor darkGrayColor].CGColor;
                
        self.velocity = KWObjectVelocityVeryFast;
        self.allure = 2.0f;
    }
    return self;
}

- (BOOL) tick:(CGFloat)dt {
    CGFloat tilt = kKWRandom(kKWAngle23Degrees);
    if ((int)tilt % 2 == 0) {
        tilt *= -1;
    }
    self.heading += tilt;
    return [super tick:dt];
}

@end
