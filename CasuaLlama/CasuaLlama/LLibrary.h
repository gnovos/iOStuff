//
//  LLibrary.h
//  CasuaLlama
//
//  Created by Mason on 9/5/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLibrary : NSObject <NSURLConnectionDownloadDelegate>

+ (id) instance;

- (void) update:(void(^)(void))completion;

@property (nonatomic, copy) void(^handler)(NKIssue* issue, NSString* asset, double progress);

@end
