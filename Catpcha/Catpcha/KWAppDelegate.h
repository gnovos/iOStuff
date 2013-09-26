//
//  KWAppDelegate.h
//  Catpcha
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

//xxx
//TODO:

//spash/level screenz (and win screens)

//game kit (and milestones, etc)
//multiplayer co-op (work together, larger field) vs head2head (steal kittens, dogs to scare away, etceteras)

//switch to opengl

//irate
//flurry

//need better collision detect and handle
//handle rapid change on heading cleaner

//kitten ai should change with level
//better ai (chase, staking, better motion states, etc)
////stalking
////crashing into each other?

//add more toys, catnip, etc.
//yarn (kittens can bat?) (trail on ground for yarn?)
//rex

//add graphics.
//graphics for play, too
//add sounds

//sort kittens by something something to improve sight?

/*
 
 void uncaughtExceptionHandler(NSException *exception) {
 [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
 }
 
 - (void)applicationDidFinishLaunching:(UIApplication *)application {
 NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
 [Flurry startSession:@"YOUR_API_KEY"];
 ....
 }
 */

@interface KWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
