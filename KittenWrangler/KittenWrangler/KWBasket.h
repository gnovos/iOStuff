//
//  KWBasket.h
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWObject.h"

@class KWKitten;

@interface KWBasket : KWObject <NSCopying>

@property (nonatomic, readonly, strong) NSMutableArray* kittens;

- (id) initWithLevel:(KWLevel*)lvl;

- (void) addKitten:(KWKitten*)kitten;
- (void) removeKitten:(KWKitten*)kitten;

@end
