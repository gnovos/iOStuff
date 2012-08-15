//
//  KWMoment.m
//  Catpcha
//
//  Created by Mason on 8/14/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWMoment.h"

@implementation KWMoment

- (id) init {
    if (self = [super init] ) {
        self.position = GLKVector2Make(0, 0);
        self.velocity = GLKVector2Make(0, 0);
        self.acceleration = GLKVector2Make(0, 0);
        
        self.rotation = 0.0f;
        self.omega = 0.0f;
        self.alpha = 0.0f;
        
        self.scale = GLKVector2Make(1.0f, 1.0f);
        self.color = white;        
    }
    return self;
}

@end
