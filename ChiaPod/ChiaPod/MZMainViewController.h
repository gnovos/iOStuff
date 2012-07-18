//
//  MZMainViewController.h
//  ChiaPod
//
//  Created by Mason on 7/2/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZFlipsideViewController.h"

@interface MZMainViewController : UIViewController <MZFlipsideViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

- (IBAction)showInfo:(id)sender;

@end
