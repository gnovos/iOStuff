//
//  KWBasket.h
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWObject.h"

@interface KWBasket : KWObject 

@property (nonatomic, readonly, strong) NSMutableArray* kittens;

- (id) initWithLevel:(KWLevel*)lvl;

@end