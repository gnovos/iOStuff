//
//  LLModelController.h
//  CasuaLlama
//
//  Created by Mason on 8/18/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLDataViewController;

@interface LLModelController : NSObject <UIPageViewControllerDataSource>

- (LLDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(LLDataViewController *)viewController;

@end
