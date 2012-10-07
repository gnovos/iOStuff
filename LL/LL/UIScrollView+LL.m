//
//  UIScrollView+MMFitToContent.m
//  Motif MVP Mobile
//
//  Created by Blazing Pair on 10/1/12.
//  Copyright (c) 2012 Blazing Cloud. All rights reserved.
//

#import "UIScrollView+LL.h"
#import "UIView+LL.h"

@implementation UIScrollView (LL)

- (void) fitToContent {
    __block CGSize fit = self.frame.size;
    [self.subviews enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
        if (view.y + view.height > fit.height) {
            fit.height = view.y + view.height;
        }
        if (view.x + view.width > fit.width) {
            fit.width = view.x + view.width;
        }

    }];    
    self.contentSize = fit;
}

@end
