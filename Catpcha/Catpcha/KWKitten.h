//
//  KWKitten.h
//  CatpchCatpchCatpcha
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWObject.h"

@class KWBasket;

@interface KWKitten : KWObject

@property (nonatomic, weak) KWBasket* basket;

- (id) initWithLevel:(KWLevel*)lvl;

- (BOOL) idle;
- (BOOL) stalking;
- (BOOL) playing;
- (BOOL) exploring;
- (BOOL) chasing;
- (BOOL) captured;

- (BOOL) bored;
- (BOOL) tired;

- (void) show:(KWObject*)toy;

@end
