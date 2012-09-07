//
//  LLLibrary.h
//  CasuaLlama
//
//  Created by Mason on 9/5/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLLibrary : NSObject <NSURLConnectionDownloadDelegate>

+ (id) instance;

@property (nonatomic, copy) void(^handler)(NKIssue* issue, NSString* asset, double progress);

@end
