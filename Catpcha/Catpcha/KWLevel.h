//
//  KWField.h
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWObject.h"

@class KWObject;

@interface KWLevel : NSObject

@property (nonatomic, readonly, assign) int level;
@property (nonatomic, readonly, assign) CGRect bounds;

@property (nonatomic, readonly, strong) NSArray* objects;

@property (nonatomic, readonly, assign) NSUInteger timelimit;

- (id) initLevel:(int)lvl;

- (void) tick:(CGFloat)dt;

- (NSArray*) sight:(KWObject*)obj;

- (NSTimeInterval) remaining;

- (BOOL) complete;

- (void) drop:(KWObject*)object;

//xxx eventually remove this?  Have only one kitten array, with basket property?
- (void) free:(NSArray*)kittens;

- (BOOL) vacant:(CGPoint)rect excluding:(KWObject*)obj;

- (NSArray*) touched:(CGPoint)point;

@end
