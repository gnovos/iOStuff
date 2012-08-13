

#import "KWEllipse.h"

#define KW_ELLIPSE_RESOLUTION 64

@implementation KWEllipse

- (NSUInteger) numVertices {
    return KW_ELLIPSE_RESOLUTION;
}

- (void) updateVertices {
    CGPoint radius = self.radius;
    for (int i = 0; i < KW_ELLIPSE_RESOLUTION; i++){
        CGFloat theta = ((CGFloat)i) / KW_ELLIPSE_RESOLUTION * M_TAU;
        self.vertices[i] = GLKVector2Make(cos(theta) * radius.x, sin(theta) * radius.y);
    }
}

- (void) setRadius:(CGPoint)radius {
    _radius = radius;
    [self updateVertices];
}


@end
