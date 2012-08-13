
#import "KWPolygon.h"

@implementation KWPolygon
- (id) initWithSides:(NSUInteger)sides andRadius:(CGFloat)radius {
    if (self = [super initWithVertices:[KWVertex build:^(KWVertex *vx) {
        for (int i = 0; i < sides; i++){
            CGFloat theta = ((CGFloat)i) / sides * M_TAU;
            [vx append:GLKVector2Make(cos(theta) * radius, sin(theta) * radius)];
        }}]]) {
    }
    return self;
}

@end
