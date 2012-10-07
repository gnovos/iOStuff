//
//  NSMutableArray+LL.h
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (LL)

- (id) pop;
- (id) shift;
- (id) yank:(NSUInteger)index;

@end
