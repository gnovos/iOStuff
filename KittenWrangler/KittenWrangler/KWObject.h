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

@interface KWObject : NSObject

@property (nonatomic, assign)           BOOL    held;

@property (nonatomic, assign)           CGFloat heading;
@property (nonatomic, assign, readonly) CGFloat rotation;

@property (nonatomic, readonly, assign) CGPoint location;
@property (nonatomic, readonly, assign) CGSize  size;
@property (nonatomic, readonly, assign) CGPoint center;

@property (nonatomic, readonly, assign) KWLevel* level;

@property (nonatomic, assign) KWObjectVelocity velocity;

@property (nonatomic, readonly, strong) CALayer* layer;


- (id) initWithLevel:(KWLevel*)lvl andSize:(CGSize)size;

- (BOOL) moving;

- (CGFloat) directionOf:(KWObject*)other;

- (void) tick:(CGFloat)dt;

@end
