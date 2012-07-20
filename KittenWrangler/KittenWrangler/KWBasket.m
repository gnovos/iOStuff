//
//  KWBasket.m
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWBasket.h"
#import "KWKitten.h"
#import "KWLevel.h"

@implementation KWBasket 

@synthesize kittens;

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:kKWDefaultBasketSize]) {
        kittens = [[NSMutableArray alloc] init];
    }
    return self;    
}

- (void) addKitten:(KWKitten*)kitten {
    [kittens addObject:kitten];
}

- (void) removeKitten:(KWKitten*)kitten {
    [kittens removeObject:kitten];
}

- (id) copyWithZone:(NSZone *)zone {
    return self;
}

- (NSString*) description {
    return [[super description] stringByAppendingFormat:@" kittens:%d", kittens.count];
}

@end
