//
//  MZView.m
//  EraseSomething
//
//  Created by Mason on 6/22/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZView.h"

@implementation MZView

- (id) init { if (self = [super init]) { [self setup]; } return self; }
- (id) initWithFrame:(CGRect)frame { if (self = [super initWithFrame:frame]) { [self setup]; } return self; }
- (id) initWithCoder:(NSCoder *)decoder { if (self = [super initWithCoder:decoder]) { [self setup]; } return self; }
- (void) setup {}

@end
