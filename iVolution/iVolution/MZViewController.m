//
//  MZViewController.m
//  iVolution
//
//  Created by Mason Glaves on 6/10/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MZViewController.h"
#import "MZAppDelegate.h"

@interface MZViewController ()

@end

@implementation MZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation -= UIInterfaceOrientationPortrait;
}

- (IBAction)sendFeedback:(id)sender {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        UIDevice* device = [UIDevice currentDevice];
        
        NSString* info = [NSString stringWithFormat:@"\nApp Version: %@\nDevice: %@ (%@)", 
                          [MZAppDelegate appVersion],
                          device.systemName,
                          device.systemVersion
                          ];
        
        NSString* body = [NSString stringWithFormat:
                          @"Dear Mason,\n\nThe best idea in the entire world is this:\n\n[[place best idea ever here]]\n\n(and you're a fool for not having already included it yet!)\n\n-=-=-=-\n\nOh, ignore this, it's just to help me tune stuff in the future:\n%@", 
                          info];
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:[NSArray arrayWithObject:@"Mason <ivolution@mason.cc>"]];
        [controller setSubject:@"So, I have an idea of where to go next with this silly app."];
        [controller setMessageBody:body isHTML:NO]; 
        if (controller) { 
            [self presentModalViewController:controller animated:YES];
        }
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"What!?" 
                                                        message:@"Why the heck can't your phone send emails?  That's just nothing but ridiculous ridiculousness, and you know it!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Shmeesh!" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        //xxx thanks, yo!
    }
    [self dismissModalViewControllerAnimated:YES];
}


@end
