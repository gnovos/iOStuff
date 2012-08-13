

#import "KWEllipse.h"

#define KW_ELLIPSE_RESOLUTION 64

@implementation KWEllipse { NSUInteger resolution; }

- (id) initWithRadius:(CGPoint)radius { return [self initWithRadius:radius atResolution:KW_ELLIPSE_RESOLUTION]; }

- (id) initWithRadius:(CGPoint)radius atResolution:(NSUInteger)res {
    if (self = [super init]) {
        resolution = res;
        for (int i = 0; i < resolution; i++){
            CGFloat theta = ((CGFloat)i) / resolution * M_TAU;
            self.vertices[i] = GLKVector2Make(cos(theta) * radius.x, sin(theta) * radius.y);
        }
    }
    return self;
}

- (NSUInteger) count { return resolution; }


@end
