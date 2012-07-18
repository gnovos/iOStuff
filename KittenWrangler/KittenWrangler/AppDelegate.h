//
//  AppDelegate.h
//  KittenWrangler
//
//  Created by Mason Glaves on 7/8/12.
//  Copyright Masonsoft 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
