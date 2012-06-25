//
//  MZViewController.m
//  EraseSomething
//
//  Created by Mason on 6/22/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZViewController.h"

@interface MZViewController ()

@end

@implementation MZViewController

- (IBAction) pop { [self.navigationController popViewControllerAnimated:YES]; }
- (IBAction) popToRoot { [self.navigationController popToRootViewControllerAnimated:YES]; }

- (IBAction) push:(id)sender {
    NSString* action = [sender accessibilityLabel];
    if (action == nil && [sender respondsToSelector:@selector(currentTitle)]) {
        action = [sender currentTitle];
    }
    
    NSString* controllerName = [NSString stringWithFormat:@"MZ%@ViewController", action];
    Class controllerClass = NSClassFromString(controllerName);
    if (controllerClass) {
        UIViewController* controller = [[controllerClass alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void) didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
