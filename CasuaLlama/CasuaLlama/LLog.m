//
//  LLog.m
//  CasuaLlama
//
//  Created by Mason on 9/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "LLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

@implementation LLog

+ (void) load {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    UIColor* pink = [UIColor colorWithRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:pink backgroundColor:nil forFlag:LOG_FLAG_INFO];
}

@end
