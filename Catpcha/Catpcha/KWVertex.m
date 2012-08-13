//
//  KWVertex.m
//  Catpcha
//
//  Created by Mason on 8/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWVertex.h"

@implementation KWVertex {
    NSUInteger count;
    NSMutableData* data;
}

- (id) init {
    if (self = [super init]) { data = [[NSMutableData alloc] init]; }
    return self;
}

+ (KWVertex*) build:(void(^)(KWVertex* vx))builder {
    KWVertex* vx = [[KWVertex alloc] init];
    builder(vx);
    return vx;
}

- (void) append:(GLKVector2)vertex {
    [data appendBytes:&vertex length:sizeof(vertex)];
    count++;
}

- (GLKVector2*) data { return (GLKVector2*) [data bytes]; }

- (NSUInteger) count { return count; }


@end
