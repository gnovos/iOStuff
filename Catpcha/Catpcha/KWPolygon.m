
#import "KWPolygon.h"

@implementation KWPolygon {
    NSUInteger sides;
}

- (id) initWithSides:(NSUInteger)count andRadius:(CGFloat)radius {
    if (self = [super init]) {
        sides = count;
        for (int i = 0; i < sides; i++){
            CGFloat theta = ((CGFloat)i) / sides * M_TAU;
            self.vertices[i] = GLKVector2Make(cos(theta) * radius, sin(theta) * radius);
        }
    }
    return self;
}

- (NSUInteger) count { return sides; }

@end
