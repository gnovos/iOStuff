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
#import "NSObject+KWO.h"

@implementation KWBasket

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:KWDefaultBasketSize]) {
        self.lineWidth = 3.0f;
        self.strokeColor = [UIColor greenColor].CGColor;
        self.lineDashPattern = @[@10, @5];
        
        self.shadowColor = [UIColor blackColor].CGColor;
        self.shadowOffset = CGSizeMake(2.0, 2.0);
        self.shadowRadius = 3.0f;
        self.shadowOpacity = 0.7f;
        
        __weak KWObject* slf = self;
        [self.level observe:@"bias" with:^(NSDictionary* change) {
            CGSize offset = [[change objectForKey:@"new"] CGSizeValue];
            offset.width *= 5.0f;
            offset.height *= 5.0f;
            slf.shadowOffset = offset;
        }];
    }
    return self;
}

- (UIBezierPath*) shape { return [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:7.0f]; }



@end
