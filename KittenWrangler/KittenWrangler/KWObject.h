//
//  KWObject.h
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KWLevel;

typedef enum {
    KWObjectVelocityMotionless = 0,
    KWObjectVelocitySlow       = 30,
    KWObjectVelocityAverage    = 80,
    KWObjectVelocityFast       = 150
} KWObjectVelocity;

@interface KWObject : CALayer

@property (nonatomic, weak) UITouch* touch;

@property (nonatomic, assign) BOOL captured;

@property (nonatomic, readonly, assign) KWLevel* level;

@property (nonatomic, assign) CGFloat heading;

@property (nonatomic, assign) KWObjectVelocity velocity;

- (id) initWithLevel:(KWLevel*)lvl andSize:(CGSize)size;

- (BOOL) moving;

- (CGFloat) directionOf:(KWObject*)other;

- (void) tick:(CGFloat)dt;

@end
