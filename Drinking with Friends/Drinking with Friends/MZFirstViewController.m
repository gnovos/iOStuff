//
//  MZFirstViewController.m
//  Drinking with Friends
//
//  Created by Mason Glaves on 6/11/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MZFirstViewController.h"

@interface MZFirstViewController ()

@end

@implementation MZFirstViewController

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
