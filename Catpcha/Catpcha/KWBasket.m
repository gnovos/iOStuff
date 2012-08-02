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

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:kKWDefaultBasketSize]) {
        self.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:7.0f].CGPath;
        self.lineWidth = 1.0f;
        self.strokeColor = [UIColor greenColor].CGColor;
        self.lineDashPattern = @[@10, @5];        
    }
    return self;    
}

@end
