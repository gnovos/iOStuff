
#import "KWRectangle.h"

@implementation KWRectangle

- (id) initWithTexture:(KWTexture*)texture andSize:(CGSize)size {
    if (self = [super initWithTexture:texture]) {
        _size = size;
        [self.geometry build:^(KWGeometry* vx) {
            vx.drawmode = GL_TRIANGLE_STRIP;
            [vx vertex:GLKVector2Make(-size.width/2.0f, -size.height/2.0f)];
            [vx vertex:GLKVector2Make( size.width/2.0f, -size.height/2.0f)];
            [vx vertex:GLKVector2Make(-size.width/2.0f,  size.height/2.0f)];
            [vx vertex:GLKVector2Make( size.width/2.0f,  size.height/2.0f)];
        }];
    }
    return self;
}

- (CGRect) bounds {
    GLKVector2 origin = self.moment.position;
    return CGRectMake(origin.x, origin.y, _size.width, _size.height);
}

@end
