//
//  KWKitten.h
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWObject.h"

@interface KWKitten : KWObject

@property (nonatomic, assign) BOOL chased;
@property (nonatomic, assign) BOOL captured;

- (id) initWithLevel:(KWLevel*)lvl;

- (BOOL) idle;
- (BOOL) stalking;
- (BOOL) exploring;
- (BOOL) chasing;

- (BOOL) bored;
- (BOOL) tired;

@end
