//
//  LHViewController.m
//  Limes Against Humanity
//
//  Created by Mason Glaves on 7/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "LHViewController.h"

@interface LHViewController ()

@end

@implementation LHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
