//
//  UIScrollView+MMFitToContent.m
//  Motif MVP Mobile
//
//  Created by Blazing Pair on 10/1/12.
//  Copyright (c) 2012 Blazing Cloud. All rights reserved.
//

#import "UIScrollView+MMFitToContent.h"

@implementation UIScrollView (MMFitToContent)

- (void) fitToContentWithPadding:(CGFloat)padding {
    __block CGFloat maxY = 0;
    [self.subviews enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
        if (view.frame.origin.y + view.frame.size.height > maxY) {
            maxY = view.frame.origin.y + view.frame.size.height;
        }
    }];
    
    CGSize resized = self.contentSize;
    resized.height = maxY + padding;
    self.contentSize = resized;
}

@end
