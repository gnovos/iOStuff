
#import "KWPolygon.h"

@implementation KWPolygon
- (id) initWithSides:(NSUInteger)sides andRadius:(CGFloat)radius {
    if (self = [super init]) {
        for (int i = 0; i < sides; i++){
            CGFloat theta = ((CGFloat)i) / sides * M_TAU;
            [self.vertices append:GLKVector2Make(cos(theta) * radius, sin(theta) * radius)];
        }
    }
    return self;
}

@end
