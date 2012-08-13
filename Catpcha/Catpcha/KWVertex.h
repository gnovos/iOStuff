//
//  KWVertex.h
//  Catpcha
//
//  Created by Mason on 8/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWVertex : NSObject

+ (KWVertex*) build:(void(^)(KWVertex* vx))builder;

- (void) append:(GLKVector2)vertex;

- (GLKVector2*)data;
- (NSUInteger)count;

@end
