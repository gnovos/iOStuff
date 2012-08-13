
#import "KWTriangle.h"

@implementation KWTriangle

- (id) init {
    if (self = [self initWithVertices:[KWVertex build:^(KWVertex *vx) {
        [vx append:GLKVector2Make(-1, -1)];
        [vx append:GLKVector2Make( 1, -1)];
        [vx append:GLKVector2Make( 0,  1)];

    }]]) {
        
    }
    return self;
}

- (NSUInteger) count { return 3; }

@end
