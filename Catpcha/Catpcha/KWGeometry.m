//
//  KWVertex.m
//  Catpcha
//
//  Created by Mason on 8/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWGeometry.h"

@implementation KWGeometry {
    NSUInteger vcount;
    NSUInteger ccount;
    NSMutableData* vertices;
    NSMutableData* colors;
    
}

- (id) initWithBlock:(void(^)(KWGeometry* vx))builder {
    if (self = [super init]) {
        self.drawmode = GL_TRIANGLE_FAN;
        builder(self);
    }
    return self;
}

- (id) init {
    if (self = [super init]) {
        vcount = ccount = 0;
        vertices = [[NSMutableData alloc] init];
        colors = [[NSMutableData alloc] init];
    }
    return self;
}

- (void) build:(void(^)(KWGeometry* vx))builder {
    builder(self);
}

- (void) vertex:(GLKVector2)vertex {
    [vertices appendBytes:&vertex length:sizeof(vertex)];
    vcount++;
}

- (void) color:(GLKVector4)color {
    [colors appendBytes:&color length:sizeof(color)];
    ccount++;
}

- (GLKVector2*) vertices { return (GLKVector2*) [vertices bytes]; }
- (NSUInteger) vcount { return vcount; }

- (GLKVector4*) colors { return (GLKVector4*) [colors bytes]; }
- (NSUInteger) ccount { return ccount; }


@end
