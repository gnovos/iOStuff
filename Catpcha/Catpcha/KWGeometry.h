//
//  KWVertex.h
//  Catpcha
//
//  Created by Mason on 8/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWGeometry : NSObject

+ (KWGeometry*) build:(void(^)(KWGeometry* vx))builder;

- (void) vertex:(GLKVector2)vertex;
- (void) color:(GLKVector4)color;

- (GLKVector2*)vertices;
- (NSUInteger)vcount;

- (GLKVector4*)colors;
- (NSUInteger)ccount;

@end
