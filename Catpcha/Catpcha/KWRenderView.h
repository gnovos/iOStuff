//
//  KWRenderView.h
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWLevel.h"

@interface KWRenderView : UIView

@property (nonatomic, weak) KWLevel* level;

- (void) tick:(CGFloat)dt;
- (void) addVelocity:(CGPoint)v;

@end
