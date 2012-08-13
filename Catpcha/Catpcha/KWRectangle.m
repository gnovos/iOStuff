
#import "KWRectangle.h"

@implementation KWRectangle

- (NSUInteger) numVertices { return 4; }

- (void) updateVertices {
    CGSize size = self.size;
    self.vertices[0] = GLKVector2Make( size.width/2.0f, -size.height/2.0f);
    self.vertices[1] = GLKVector2Make( size.width/2.0f,  size.height/2.0f);
    self.vertices[2] = GLKVector2Make(-size.width/2.0f,  size.height/2.0f);
    self.vertices[3] = GLKVector2Make(-size.width/2.0f, -size.height/2.0f);
}

- (void) setSize:(CGSize)size {
    _size = size;
    [self updateVertices];
}

@end
