//
//  MZRootViewController.m
//  EraseSomething
//
//  Created by Mason on 6/22/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZRootViewController.h"
#import "MZGameCenter.h"

@implementation MZRootViewController

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL) animated {
    [super viewDidAppear:animated];
}

- (IBAction) login {
    [MZGameCenter authenticate];
}

@end
