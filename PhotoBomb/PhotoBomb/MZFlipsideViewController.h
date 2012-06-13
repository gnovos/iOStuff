//
//  MZFlipsideViewController.h
//  PhotoBomb
//
//  Created by Mason on 6/12/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MZFlipsideViewController;

@protocol MZFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(MZFlipsideViewController *)controller;
@end

@interface MZFlipsideViewController : UIViewController

@property (weak, nonatomic) id <MZFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
