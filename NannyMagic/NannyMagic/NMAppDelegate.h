//
//  NMAppDelegate.h
//  NannyMagic
//
//  Created by Mason Glaves on 5/16/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NMViewController;

@interface NMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NMViewController *viewController;

@end
