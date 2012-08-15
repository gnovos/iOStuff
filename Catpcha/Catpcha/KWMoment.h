//
//  KWMoment.h
//  Catpcha
//
//  Created by Mason on 8/14/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWMoment : NSObject

@property (nonatomic, assign) GLKVector2 position;
@property (nonatomic, assign) GLKVector2 velocity;
@property (nonatomic, assign) GLKVector2 acceleration;

@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat omega; //angular velocity
@property (nonatomic, assign) CGFloat alpha; //angular acceleration

@property (nonatomic, assign) GLKVector2 scale;
@property (nonatomic, assign) GLKVector4 color;

@end
