
#import "KWRectangle.h"

@implementation KWRectangle

- (id) initWithTexture:(KWTexture*)texture andSize:(CGSize)size {
    if (self = [super initWithTexture:texture]) {
        [self.vertices append:GLKVector2Make( size.width/2.0f, -size.height/2.0f)];
        [self.vertices append:GLKVector2Make( size.width/2.0f,  size.height/2.0f)];
        [self.vertices append:GLKVector2Make(-size.width/2.0f,  size.height/2.0f)];
        [self.vertices append:GLKVector2Make(-size.width/2.0f, -size.height/2.0f)];
    }
    return self;
}

@end
