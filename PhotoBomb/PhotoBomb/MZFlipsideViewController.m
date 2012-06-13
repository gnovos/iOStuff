//
//  MZFlipsideViewController.m
//  PhotoBomb
//
//  Created by Mason on 6/12/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZFlipsideViewController.h"

@interface MZFlipsideViewController ()

@end

@implementation MZFlipsideViewController

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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
