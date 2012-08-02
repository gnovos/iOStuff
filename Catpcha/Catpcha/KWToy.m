//
//  KWToy.m
//  Catpcha
//
//  Created by Mason on 7/22/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWToy.h"

@implementation KWToy

- (id) initWithLevel:(KWLevel *)lvl andSize:(CGSize)size {
    if (self = [super initWithLevel:lvl andSize:size]) {
        self.allure = 0.8f;
        self.catchable = YES;
    }
    return self;
    
}


@end
