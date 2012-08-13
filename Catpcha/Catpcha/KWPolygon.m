
#import "KWPolygon.h"

@implementation KWPolygon {
    NSUInteger sides;
    CGFloat radius;
}

- (id) initWithSides:(NSUInteger)count andRadius:(CGFloat)r {
    if (self = [super init]) {
        sides = count;
        radius = r;
        [self updateVertices];
    }
    return self;
}

- (NSUInteger) numVertices {
    return sides;
}

- (void) updateVertices {
    for (int i = 0; i < sides; i++){
        CGFloat theta = ((CGFloat)i) / sides * M_TAU;
        self.vertices[i] = GLKVector2Make(cos(theta)*radius, sin(theta)*radius);
    }
}


@end
