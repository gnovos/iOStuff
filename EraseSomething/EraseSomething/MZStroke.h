//
//  MZStroke.h
//  EraseSomething
//
//  Created by Mason on 7/2/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MZBrush;

@interface MZStroke : NSObject <NSCoding>

@property (nonatomic, assign) CGPoint start;
@property (nonatomic, assign) CGPoint end;

@property (nonatomic, assign) CGFloat red;
@property (nonatomic, assign) CGFloat green;
@property (nonatomic, assign) CGFloat blue;
@property (nonatomic, assign) CGFloat alpha;

@property (nonatomic, assign) NSDate* added;

@property (nonatomic, strong) MZBrush* brush;

@end
