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
        self.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:7.0f].CGPath;
        self.lineWidth = 1.0f;
        self.strokeColor = [UIColor greenColor].CGColor;
        self.lineDashPattern = @[@10, @5];
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
    self.lineDashPhase++;
        
    return [super tick:dt];
}

- (void) addKitten:(KWKitten*)kitten {
    [kittens addObject:kitten];
}

@end
