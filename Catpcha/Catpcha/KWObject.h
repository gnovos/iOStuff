//
//  KWObject.h
//  Catpcha
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KWLevel;

typedef enum {
    KWObjectVelocityMotionless = 0,
    KWObjectVelocityVerySlow   = 5,
    KWObjectVelocitySlow       = 50,
    KWObjectVelocityAverage    = 100,
    KWObjectVelocityFast       = 150,
    KWObjectVelocityVeryFast   = 200,
} KWObjectVelocity;

@interface KWObject : CAShapeLayer

@property (nonatomic, assign) CGFloat allure;

@property (nonatomic, assign) BOOL touchable;
@property (nonatomic, assign) BOOL catchable;

@property (nonatomic, weak) UITouch* touch;
@property (nonatomic, readonly, assign) KWLevel* level;
@property (nonatomic, assign) CGFloat heading;
@property (nonatomic, assign) KWObjectVelocity velocity;

- (id) initWithLevel:(KWLevel*)lvl andSize:(CGSize)size;

- (UIBezierPath*) shape;

- (BOOL) moving;

- (BOOL) tick:(CGFloat)dt;

- (CGFloat) direction:(KWObject*)other;

- (void) grab;
- (void) drop;


@end
