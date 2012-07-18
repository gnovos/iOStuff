//
//  KWBasket.m
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWBasket.h"
#import "KWKitten.h"

static const CGSize kKWDefaultBasketSize = { 50, 50 };

@implementation KWBasket 

@synthesize kittens;

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:kKWDefaultBasketSize]) {
        kittens = [[NSMutableArray alloc] init];
    }
    return self;    
}

- (NSString*) description {
    return [[super description] stringByAppendingFormat:@" kittens:%d", kittens.count];
}

@end
