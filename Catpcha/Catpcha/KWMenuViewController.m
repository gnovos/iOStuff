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

- (void) prepare {
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite* invite, NSArray *players) {
        //xxx cleanup game in progress if required?
        if (invite) {
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:invite];
            mmvc.matchmakerDelegate = self;
            [self presentModalViewController:mmvc animated:YES];
        } else if (players) {
            [self requestMatch:players];
        }
    };
}

- (void) login {
    //xxx check if already authenticated?
    [KWEngine.instance authenticate:^{
        [self prepare];
    } failure:^(NSError* error){
        NSString* message = [NSString stringWithFormat:@"We couldn't authenticate with Game Genter because of this: '%@'  :(  Without authenticating with game center you'll find gameplay kinda limited.", [error localizedDescription]];
        [KWAlert alert:@"Oh Meow!"
               message:message
               actions:@{ @"Okay": ^{ [self prepare]; }, @"Try Again" : ^{ [self login]; } }];
    }];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [KWEngine.instance attach:self forEvent:KWEngineEventMatchBegin withHandler:^(id target, id data) { [self start]; }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//xxxz    [self login];
    [self start];
}

- (void) requestMatch:(NSArray*)players {
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    request.playersToInvite = players;
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    [self presentModalViewController:mmvc animated:YES];    
}

- (void) start {
    UIViewController* game = [self.storyboard instantiateViewControllerWithIdentifier:@"Renderer"];
    [UIView transitionFromView:self.view toView:game.view duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [self.navigationController pushViewController:game animated:NO];
    }];
}

- (IBAction) singlePlayer { [self start]; }
- (IBAction) multiPlayer { [self requestMatch:nil]; }

- (void) matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)matchmaker { [self dismissModalViewControllerAnimated:YES]; }
- (void) matchmakerViewController:(GKMatchmakerViewController*)matchmaker didFailWithError:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
    elog(error);
}

- (void) matchmakerViewController:(GKMatchmakerViewController*)matchmaker didFindMatch:(GKMatch*)match {
    [self dismissModalViewControllerAnimated:YES];
    [KWEngine.instance setMatch:match];
}

@end
