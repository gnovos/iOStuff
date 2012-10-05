//
//  UILabel+MMResizeToFit.m
//  Motif MVP Mobile
//
//  Created by Blazing Pair on 10/1/12.
//  Copyright (c) 2012 Blazing Cloud. All rights reserved.
//

#import "UILabel+LLText.h"

@implementation UILabel (LLText)

- (void) fitToText {
    
    CGSize textSize = [self.text sizeWithFont:self.font
                            constrainedToSize:CGSizeMake(self.frame.size.width, MAXFLOAT)
                                lineBreakMode:self.lineBreakMode];
    
    self.frame = (CGRect) {self.frame.origin, textSize};
}

@end
