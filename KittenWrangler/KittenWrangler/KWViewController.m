//
//  KWViewController.m
//  KittenWrangler
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWViewController.h"
#import "KWEngine.h"

@interface KWViewController ()

@end

@implementation KWViewController {
    KWEngine* engine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    engine = [[KWEngine alloc] init];
}

- (void) viewDidAppear:(BOOL)animated {
    [self viewDidAppear:animated];
        
    [engine start];
    
}

@end
