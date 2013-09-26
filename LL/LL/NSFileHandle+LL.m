//
//  NSFileHandle+LL.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "NSFileHandle+LL.h"

@implementation NSFileHandle (LL)

- (NSString*) md5 {
    CC_MD5_CTX md5;
    
    CC_MD5_Init(&md5);
    
    BOOL done = NO;
    while(!done) {
        
        NSData* fileData = [self readDataOfLength: 32 * 1024 ];
        
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        
        if ([fileData length] == 0) { done = YES; }
        
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_Final(digest, &md5);
    return [[NSString stringWithFormat:
             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
             digest[0],  digest[1],  digest[2],  digest[3],
             digest[4],  digest[5],  digest[6],  digest[7],
             digest[8],  digest[9],  digest[10], digest[11],
             digest[12], digest[13], digest[14], digest[15]] lowercaseString];
}



@end
