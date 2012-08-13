
#import "KWAnimation.h"

@implementation KWAnimation

@synthesize elapsed, duration, dpos, dscale, drot, dcolor;

- (id) init {
    if (self = [super init]) {
        elapsed = 0;
        duration = 0;
        dpos = GLKVector2Make(0,0);
        drot = 0;
        dscale = GLKVector2Make(0,0);
        dcolor = GLKVector4Make(0,0,0,0);
    }
    return self;
}

- (void) animateShape:(KWShape*)shape dt:(NSTimeInterval)dt {
    elapsed += dt;
    
    if (elapsed > duration) {
        dt -= elapsed - duration;
    }
    
    CGFloat fractionOfDuration = dt/duration;
    
    GLKVector2 positionIncrement = GLKVector2MultiplyScalar(dpos, fractionOfDuration);
    shape.position = GLKVector2Add(shape.position, positionIncrement);
    
    GLKVector4 colorIncrement = GLKVector4MultiplyScalar(dcolor, fractionOfDuration);
    shape.color = GLKVector4Add(shape.color, colorIncrement);
    
    GLKVector2 scaleIncrement = GLKVector2MultiplyScalar(dscale, fractionOfDuration);
    shape.scale = GLKVector2Add(shape.scale, scaleIncrement);
    
    shape.rotation += drot * fractionOfDuration;
}

@end
