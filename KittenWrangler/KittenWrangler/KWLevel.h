//
//  KWField.h
//  KittenWrangler
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KWObject, KWBasket, KWKitten;

@interface KWLevel : NSObject

@property (nonatomic, readonly, assign) int level;
@property (nonatomic, readonly, assign) CGRect bounds;

@property (nonatomic, readonly, strong) NSArray* baskets;
@property (nonatomic, readonly, strong) NSArray* kittens;
@property (nonatomic, readonly, strong) NSArray* toys;

- (id) initLevel:(int)lvl;

- (void) tick:(CGFloat)dt;

- (NSArray*) visible:(KWObject*)obj;

- (NSTimeInterval) remaining;

- (BOOL) complete;

- (void) move:(KWKitten*)kitten toBasket:(KWBasket*)basket;

- (BOOL) vacant:(CGRect)rect excluding:(KWObject*)obj;

@end
