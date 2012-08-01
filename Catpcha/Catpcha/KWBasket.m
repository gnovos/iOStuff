//
//  KWBasket.m
//  Catpcha
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWBasket.h"
#import "KWKitten.h"
#import "KWLevel.h"

@implementation KWBasket 

@synthesize kittens;

- (NSString*) description {
    return [[super description] stringByAppendingFormat:@" kittens:%d", kittens.count];
}

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:kKWDefaultBasketSize]) {
        kittens = [[NSMutableArray alloc] init];
    }
    return self;    
}

- (BOOL) tick:(CGFloat)dt {
    
    [[kittens copy] enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
        if (kitten.bored) {
            [kittens removeObject:kitten];
            [self.level free:kitten];
        } else {
            [kitten tick:dt];
        }
    }];
        
    return [super tick:dt];
}

- (void) addKitten:(KWKitten*)kitten {
    [kittens addObject:kitten];
}

- (void) drawInContext:(CGContextRef)ctx {
    [[[[[KWGFX alloc] initWithContext:ctx] width:2.0f] stroke:[UIColor greenColor]] rect:self.bounds];
}

@end
