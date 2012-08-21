//
//  LLAppDelegate.h
//  CasuaLlama
//
//  Created by Mason on 8/18/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

+ (LLAppDelegate*) instance;

@property (nonatomic, strong) IBOutlet UIWindow* window;
@property (nonatomic, strong) NSUserDefaults* settings;

- (NSURL*) documents;

- (void) alert:(NSString*)action message:(NSString*)message;
- (void) raise:(NSError*)error;
- (void) open:(NSURL*)url;

- (void) notify;


@end
