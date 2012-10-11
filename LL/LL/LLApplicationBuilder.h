//
//  LLApplicationBuilder.h
//  LL
//
//  Created by Mason on 10/5/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "LLViewController.h"

@interface LLApplicationBuilder : NSObject

@property (nonatomic, strong) NSDictionary* data;
@property (nonatomic, strong) NSDictionary* views;

- (void) build:(NSString*)resource;

- (LLViewController*) create:(NSString*)view;

@end
