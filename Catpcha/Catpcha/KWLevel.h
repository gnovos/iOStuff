//
//  KWField.h
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWObject.h"

@class KWObject, KWKitten;

@interface KWLevel : CALayer

@property (nonatomic, readonly, assign) int level;
@property (nonatomic, readonly, assign) NSUInteger timelimit;
@property (nonatomic, readonly, strong) NSArray* objects;

- (id) initLevel:(int)lvl;

- (void) tick:(CGFloat)dt;

- (NSArray*) sight:(KWObject*)obj;

- (NSTimeInterval) remaining;

- (BOOL) complete;

- (void) drop:(KWObject*)object;

//xxx eventually remove this?  Have only one kitten array, with basket property?
- (void) free:(KWKitten*)kitten;

- (BOOL) vacant:(CGPoint)rect excluding:(KWObject*)obj;

- (NSArray*) touched:(CGPoint)point;

@end
