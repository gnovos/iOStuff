//
//  KWField.h
//  KittenWrangler
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWLevel : NSObject

@property (nonatomic, readonly, assign) NSUInteger level;

@property (nonatomic, readonly, assign) CGRect bounds;

- (id) initLevel:(NSUInteger)lvl;

- (void) tick:(CGFloat)dt;

- (BOOL) complete;

@end
