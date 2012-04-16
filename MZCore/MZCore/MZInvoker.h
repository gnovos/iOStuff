//
//  MZInvoker.h
//  MZCore
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZInvoker : NSProxy {
    id parent;
    NSThread* thread;
}

- (id) initWithTarget:(id)target;
- (id) initWithTarget:(id)target andThread:(NSThread*)thread;

@end
