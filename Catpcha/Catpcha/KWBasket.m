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
#import "NSObject+KW.h"

@implementation KWBasket

- (id) initWithLevel:(KWLevel*)lvl {
    if (self = [super initWithLevel:lvl andSize:KWBasketSize]) {
        self.type = KWObjectTypeBasket;
        //xxxz
//        self.lineWidth = 3.0f;
//        self.strokeColor = [UIColor greenColor].CGColor;
//        self.lineDashPattern = @[@10, @5];
//        
//        self.shadowColor = [UIColor blackColor].CGColor;
//        self.shadowOffset = CGSizeMake(2.0, 2.0);
//        self.shadowRadius = 3.0f;
//        self.shadowOpacity = 0.7f;
//        self.shouldRasterize = YES;
        
        __weak KWObject* slf = self;
//xxxz        
//        [self.level observe:@"bias" with:^(NSDictionary* change) {
//            CGSize offset = [[change objectForKey:@"new"] CGSizeValue];
//            offset.width *= 3.0f;
//            offset.height *= 3.0f;
////xxxz            slf.shadowOffset = offset;
//        }];
    }
    return self;
}

//xxxz- (UIBezierPath*) shape { return [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:7.0f]; }



@end
