//
//  KWField.h
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWRectangle.h"

@class KWObject, KWKitten;

@interface KWLevel : KWRectangle

@property (nonatomic, readonly, assign) int level;
@property (nonatomic, readonly, assign) NSUInteger timelimit;
@property (nonatomic, readonly, strong) NSArray* objects;
@property (nonatomic, readonly, strong) NSArray* kittens;
@property (nonatomic, readonly, strong) NSArray* baskets;

@property (nonatomic, assign) CGPoint bias;

- (id) initLevel:(int)lvl withSize:(CGSize)size;

- (void) populate;

- (void) tick:(CGFloat)dt;

- (NSArray*) sight:(KWObject*)obj;

- (NSTimeInterval) remaining;

- (BOOL) complete;
- (BOOL) solved;

- (void) capture:(KWObject*)object;

- (NSArray*) touched:(CGPoint)point;

@end
