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
    } failure:^(NSError* error){
        NSString* message = [NSString stringWithFormat:@"We couldn't authenticate with Game Genter because of this: '%@'  :(  Without authenticating with game center you'll find gameplay kinda limited.", [error localizedDescription]];
        [KWAlert alert:@"Oh Meow!"
               message:message
               actions:@{ @"Okay": ^{ [self start]; }, @"Try Again" : ^{ [self login]; } }];
    }];
}

- (void) start {
    NSLog(@"xxxx auth");
    
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        NSLog(@"accepted: %@ invited: %@", acceptedInvite, playersToInvite);
        // Insert application-specific code here to clean up any games in progress.
        if (acceptedInvite) {
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite];
            mmvc.matchmakerDelegate = self;
            [self presentModalViewController:mmvc animated:YES];
        } else if (playersToInvite) {
            GKMatchRequest *request = [[GKMatchRequest alloc] init];
            request.minPlayers = 2;
            request.maxPlayers = 4;
            request.playersToInvite = playersToInvite;
            
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
            mmvc.matchmakerDelegate = self;
            [self presentModalViewController:mmvc animated:YES];
        }
    };

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self login];
}

- (IBAction) singlePlayer {
    UIViewController* game = [self.storyboard instantiateViewControllerWithIdentifier:@"Renderer"];
    [UIView transitionFromView:self.view toView:game.view duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [self.navigationController pushViewController:game animated:NO];
    }];
    
}

- (IBAction) multiPlayer {
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    
//    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch* match, NSError *error) {
//        elog(error);
//        NSLog(@"match is %@", match);
//    }];

    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    
    [self presentModalViewController:mmvc animated:YES];
}

- (void) matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)matchmaker {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"match cancelled");
}

- (void) matchmakerViewController:(GKMatchmakerViewController*)matchmaker didFailWithError:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"match error %@", error);
}

- (void) matchmakerViewController:(GKMatchmakerViewController*)matchmaker didFindMatch:(GKMatch*)match {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"match find %@", match);
    
//    self.myMatch = match; // Use a retaining property to retain the match.
//    match.delegate = self;
//    if (!self.matchStarted && match.expectedPlayerCount == 0)
//    {
//        self.matchStarted = YES;
//        // Insert application-specific code to begin the match.
//    }
}

- (void) matchmakerViewController:(GKMatchmakerViewController*)matchmaker didReceiveAcceptFromHostedPlayer:(NSString*)playerID {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"match accept %@", playerID);
}

@end
