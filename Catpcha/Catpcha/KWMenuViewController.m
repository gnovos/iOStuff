//
//  KWLaunchViewController.m
//  Catpcha
//
//  Created by Mason on 8/7/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWMenuViewController.h"
#import "KWAlert.h"
#import "KWEngine.h"

@interface KWMenuViewController ()

@end

@implementation KWMenuViewController

- (void) login {
    //xxx check if already authenticated?
    [KWEngine.instance authenticate:^{
        [self start];
    } failure:^{
        [KWAlert alert:@"Oh Meow!"
               message:@"We couldn't authenticate with Game Genter.  :(  Without authenticating with game center you'll find gameplay kinda limited."
               actions:@{ @"Okay": ^{ [self start]; }, @"Try Again" : ^{ [self login]; } }];
    }];
}

- (void) start {
    UIViewController* game = [self.storyboard instantiateViewControllerWithIdentifier:@"Renderer"];
    [UIView transitionFromView:self.view toView:game.view duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [self.navigationController pushViewController:game animated:NO];
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self login];
}

@end
