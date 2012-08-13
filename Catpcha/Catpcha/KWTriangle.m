
#import "KWTriangle.h"

@implementation KWTriangle

- (id) initWithTexture:(KWTexture *)tex {
    if (self = [self initWithTexture:tex]) {
        [self.vertices append:GLKVector2Make(0.0, 1.0)];
        [self.vertices append:GLKVector2Make( -1.0, -1.0)];
        [self.vertices append:GLKVector2Make( 1.0,  -1.0)];
    }
    return self;
}

@end
