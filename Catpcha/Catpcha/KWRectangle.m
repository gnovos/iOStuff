
#import "KWRectangle.h"

@implementation KWRectangle

- (id) initWithSize:(CGSize)size {
    if (self = [super init]) {
        self.vertices[0] = GLKVector2Make( size.width/2.0f, -size.height/2.0f);
        self.vertices[1] = GLKVector2Make( size.width/2.0f,  size.height/2.0f);
        self.vertices[2] = GLKVector2Make(-size.width/2.0f,  size.height/2.0f);
        self.vertices[3] = GLKVector2Make(-size.width/2.0f, -size.height/2.0f);
    }
    return self;
}

- (NSUInteger) count { return 4; }


@end
