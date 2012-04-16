//
//  MZFlipsideViewController.h
//  detox
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
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
