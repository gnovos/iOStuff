//
//  LLLibrary.m
//  CasuaLlama
//
//  Created by Mason on 9/5/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "LLLibrary.h"

#define kLLRESOURCE_URL @"http://cassuallama.org/api/v1/editons/"

@implementation LLLibrary {
    NKLibrary* library;    
    NSURL* resources;
}

LL_INIT_SINGELTON

- (id) init {
    if (self = [super init]) {
        resources = [NSURL URLWithString:kLLRESOURCE_URL];
        library = [NKLibrary sharedLibrary];
    }
    return self;
}

- (void) update {
    [library.downloadingAssets enumerateObjectsUsingBlock:^(NKAssetDownload* asset, NSUInteger idx, BOOL *stop) {
        [asset downloadWithDelegate:self];
    }];
    
    //xxx do this instead of MK or somesuch?
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray* issues = [NSArray arrayWithContentsOfURL:[resources URLByAppendingPathComponent:@"issues.plist"]];
        
        [issues enumerateObjectsUsingBlock:^(NSDictionary* edition, NSUInteger idx, BOOL *stop) {
            NSString* identifier = [edition objectForKey:@"identifier"];
            NKIssue* issue = [library issueWithName:identifier];
            if (!issue) {
                NSURL* source = [resources URLByAppendingPathComponent:issue.name isDirectory:YES];
                
                NSDate* date = [edition objectForKey:@"date"];
                issue = [library addIssueWithName:identifier date:date];
                
                NSURL* content = [source URLByAppendingPathComponent:@"content.plist"];
                [self download:nil from:content forIssue:issue];                
            }
        }];
    });
}

- (void) connectionDidFinishDownloading:(NSURLConnection*)connection destinationURL:(NSURL*)destination {
    NKAssetDownload* download = connection.newsstandAssetDownload;
    NKIssue* issue = download.issue;
    NSDictionary* info = download.userInfo;
        
    NSString* asset = [info objectForKey:@"asset"];
    if (!asset) {
        NSURL* source = [resources URLByAppendingPathComponent:issue.name isDirectory:YES];
        
        NSDictionary* edition = [NSDictionary dictionaryWithContentsOfURL:destination];
        NSMutableDictionary* assets = [edition objectForKey:@"assets"];
        
        [assets enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSString* path, BOOL *stop) {
            NSURL* url;
            if ([path hasPrefix:@"http://"] || [path hasPrefix:@"file://"]) {
                url = [NSURL URLWithString:path];
            } else {
                url = [source URLByAppendingPathComponent:path];
            }
            [self download:name from:url forIssue:issue];
        }];
        
        asset = @"content.plist";
    }
    
    NSURL* path = [issue.contentURL URLByAppendingPathComponent:asset];
    NSError* error;
    if (![[NSFileManager defaultManager] moveItemAtURL:destination toURL:path error:&error]) {
        elog(error);
    }
}

- (void) connection:(NSURLConnection*)connection didWriteData:(long long)bytes totalBytesWritten:(long long)total expectedTotalBytes:(long long)expected {
    NKAssetDownload* download = connection.newsstandAssetDownload;
    double progress = (double)total / (double)expected;
    if (self.handler) {
        self.handler(download.issue, [download.userInfo objectForKey:@"asset"], progress);
    }
}

- (void) download:(NSString*)asset from:(NSURL*)url forIssue:(NKIssue*)issue {
    NKAssetDownload* download = [issue addAssetWithRequest:[NSURLRequest requestWithURL:url]];
    if (asset) { download.userInfo = @{ @"asset" : asset }; }
    [download downloadWithDelegate:self];
}

@end
