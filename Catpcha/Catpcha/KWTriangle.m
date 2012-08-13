
#import "KWTriangle.h"

@implementation KWTriangle

- (id) initWithTexture:(KWTexture *)tex {
    if (self = [self initWithTexture:tex]) {
        [self.vertices append:GLKVector2Make(-1, -1)];
        [self.vertices append:GLKVector2Make( 1, -1)];
        [self.vertices append:GLKVector2Make( 0,  1)];        
    }
    return self;
}

- (NSUInteger) count { return 3; }

@end
