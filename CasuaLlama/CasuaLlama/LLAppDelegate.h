//
//  LLAppDelegate.h
//  CasuaLlama
//
//  Created by Mason on 8/18/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLLibrary.h"

@interface LLAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

+ (LLAppDelegate*) instance;

- (NSURL*) documents;

- (void) alert:(NSString*)action message:(NSString*)message;
- (void) raise:(NSError*)error;
- (void) open:(NSURL*)url;

- (UIStoryboard*) storyboard;
- (UIViewController*) root;
- (UINavigationController*) nav;
- (UIApplication*) application;

- (void) notify;

@property (nonatomic, strong) IBOutlet UIWindow* window;
@property (nonatomic, strong) NSUserDefaults* settings;
@property (nonatomic, strong) LLLibrary* library;

@end
