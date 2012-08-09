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
    if (self = [super initWithLevel:lvl andSize:KWDefaultMouseSize]) {
        self.type = KWObjectTypeMouse;
        self.fillColor = [UIColor darkGrayColor].CGColor;
                
        self.velocity = KWObjectVelocityVeryFast;
        self.allure = 2.0f;
    }
    return self;
}

- (UIBezierPath*) shape { return [UIBezierPath bezierPathWithOvalInRect:self.bounds]; }

- (BOOL) tick:(CGFloat)dt {
    CGFloat tilt = KWRandom(KWAngle23Degrees);
    if ((int)tilt % 2 == 0) {
        tilt *= -1;
    }
    self.heading += tilt;
    return [super tick:dt];
}

@end
