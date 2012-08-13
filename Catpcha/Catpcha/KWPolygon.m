
#import "KWPolygon.h"

@implementation KWPolygon

- (id) initWithTexture:(KWTexture*)texture andSides:(NSUInteger)sides withRadius:(CGFloat)radius {
    if (self = [super initWithTexture:texture]) {
        for (int i = 0; i < sides; i++){
            CGFloat theta = ((CGFloat)i) / sides * M_TAU;
            [self.vertices append:GLKVector2Make(cos(theta) * radius, sin(theta) * radius)];
        }
    }
    return self;
}

@end
