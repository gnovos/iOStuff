//
//  LLViewController.h
//  CasuaLlama
//
//  Created by Mason on 8/19/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

@interface LLViewController : UIViewController <UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, weak) LLAppDelegate* app;

- (void) configure;
- (void) fade:(NSString*)to duration:(NSTimeInterval)duration; //xxx

- (void) setBackground:(id)background;
- (void) setNav:(id)nav;

@end
