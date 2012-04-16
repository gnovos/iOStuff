//
//  MZSplashViewController.m
//  malk
//
//  Created by Mason Glaves on 4/10/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MZSplashViewController.h"

@interface MZSplashViewController ()

@end

@implementation MZSplashViewController

@synthesize intro, outtro;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:2.0f animations:^{
        intro.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0f animations:^{
            intro.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:2.0f animations:^{
                outtro.alpha = 0.45f;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5f animations:^{
                    outtro.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    
                    [self performSegueWithIdentifier:@"SplashComplete" sender:self];
                    
                }];
            }];
        }];
        
    }];
}

@end
