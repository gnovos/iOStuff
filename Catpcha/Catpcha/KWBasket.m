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

- (void) tick:(CGFloat)dt {
    
    NSMutableArray* escaped = [[NSMutableArray alloc] init];
    
    [kittens enumerateObjectsUsingBlock:^(KWKitten* kitten, NSUInteger idx, BOOL *stop) {
        if (kitten.bored) {
            [escaped addObject:kitten];
        } else {
            [kitten tick:dt];
        }
    }];
    [kittens removeObjectsInArray:escaped];
    
    [self.level free:escaped];
    
    [super tick:dt];
}

- (void) addKitten:(KWKitten*)kitten {
    [kittens addObject:kitten];
}

- (void) drawInContext:(CGContextRef)ctx {
    [[[[[KWGFX alloc] initWithContext:ctx] width:2.0f] stroke:[UIColor greenColor]] rect:self.bounds];
}

@end
