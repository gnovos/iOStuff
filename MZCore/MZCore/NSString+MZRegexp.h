//
//  NSString+MZRegexp.h
//  MZCore
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MZRegexp)

- (BOOL) matches:(NSString*)pattern;
- (NSString*) capture:(NSString*)pattern;
- (NSArray*) captures:(NSString*)pattern;

@end
