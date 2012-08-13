

#import "KWEllipse.h"

#define KW_ELLIPSE_RESOLUTION 64

@implementation KWEllipse

- (id) initWithTexture:(KWTexture*)texture andRadius:(CGPoint)radius { return [self initWithTexture:texture andRadius:radius atResolution:KW_ELLIPSE_RESOLUTION]; }
- (id) initWithTexture:(KWTexture*)texture andRadius:(CGPoint)radius atResolution:(NSUInteger)resolution {
    if (self = [super initWithTexture:texture]) {
        for (int i = 0; i < resolution; i++){
            CGFloat theta = ((CGFloat)i) / resolution * M_TAU;
            [self.vertices append:GLKVector2Make(cos(theta) * radius.x, sin(theta) * radius.y)];
        }
    }
    return self;
}

@end
