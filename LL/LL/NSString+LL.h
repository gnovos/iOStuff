//
//  NSString+LLUtil.h
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//


@interface NSString (LL)

+ (NSString*) digest:(unsigned char*)digest length:(int)length;
- (NSString*) md5;
- (NSString*) sha1;
- (BOOL) matches:(id)pattern;
- (NSString*) match:(id)pattern;
- (NSArray*) capture:(id)pattern;
- (NSArray*) split:(NSString*)delimiter;

- (BOOL) empty;
- (BOOL) notEmpty;

@end
