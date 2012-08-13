
#import "KWAnimation.h"

@implementation KWAnimation

@synthesize elapsed, duration, delta;

- (id) init {
    if (self = [super init]) {
        elapsed = 0;
        duration = 0;
        delta = KWDeltaMake(GLKVector2Make(0,0), GLKVector2Make(0,0), 0, GLKVector4Make(0,0,0,0));
    }
    return self;
}

- (void) animate:(KWShape*)shape dt:(NSTimeInterval)dt {
    elapsed += dt;
    
    if (elapsed > duration) {
        dt -= elapsed - duration;
    }
    
    CGFloat fractionOfDuration = dt/duration;
    
    GLKVector2 positionIncrement = GLKVector2MultiplyScalar(delta.position, fractionOfDuration);
    shape.position = GLKVector2Add(shape.position, positionIncrement);
        
    GLKVector2 scaleIncrement = GLKVector2MultiplyScalar(delta.scale, fractionOfDuration);
    shape.scale = GLKVector2Add(shape.scale, scaleIncrement);
    
    shape.rotation += delta.rotation * fractionOfDuration;
    
    GLKVector4 colorIncrement = GLKVector4MultiplyScalar(delta.color, fractionOfDuration);
    shape.color = GLKVector4Add(shape.color, colorIncrement);

}

@end
