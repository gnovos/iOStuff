//
//  KWInterstitialViewController.m
//  Catpcha
//
//  Created by Mason on 8/7/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWInterstitialViewController.h"

@interface KWInterstitialViewController ()

//@property (weak, nonatomic) IBOutlet UILabel *message;

@end

@implementation KWInterstitialViewController

- (void)viewDidUnload {
    [self setMessage:nil];
    [super viewDidUnload];
}
@end
