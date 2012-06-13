//
//  MZViewController.m
//  FlipDraw
//
//  Created by Mason on 6/12/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZViewController.h"

@interface MZViewController ()

@end

@implementation MZViewController {
    IBOutlet UIView *flipScreen;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [UIView transitionWithView:flipScreen
                      duration:5.0f
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                    }
                    completion:^(BOOL finished) {
                        
                    }];
    
//    [UIView animateWithDuration:5.0f animations:^{
//        
//    } completion:^(BOOL finished) {
//        NSLog(@"done is %d", finished);
//    }];
    
}

@end
