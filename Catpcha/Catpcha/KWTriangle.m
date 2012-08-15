
#import "KWTriangle.h"

@implementation KWTriangle

- (id) initWithTexture:(KWTexture *)tex {
    if (self = [self initWithTexture:tex]) {
        [self.geometry vertex:GLKVector2Make(0.0, 1.0)];
        [self.geometry vertex:GLKVector2Make( -1.0, -1.0)];
        [self.geometry vertex:GLKVector2Make( 1.0,  -1.0)];
    }
    return self;
}

@end
