

#import "KWEllipse.h"

#define KW_ELLIPSE_RESOLUTION 64

@implementation KWEllipse

- (id) initWithRadius:(CGPoint)radius { return [self initWithRadius:radius atResolution:KW_ELLIPSE_RESOLUTION]; }
- (id) initWithRadius:(CGPoint)radius atResolution:(NSUInteger)resolution {
    if (self = [super initWithVertices:[KWVertex build:^(KWVertex *vx) {
        for (int i = 0; i < resolution; i++){
            CGFloat theta = ((CGFloat)i) / resolution * M_TAU;
            [vx append:GLKVector2Make(cos(theta) * radius.x, sin(theta) * radius.y)];
        }}]]) {
    }
    return self;
}

@end
