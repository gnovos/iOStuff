//
//  NSObject+MZThreading.h
//  MZCore
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MZThreading)

- (id) main;

- (id) thread:(NSThread*)thread;

@end
