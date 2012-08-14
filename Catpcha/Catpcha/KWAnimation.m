
#import "KWAnimation.h"

@implementation KWAnimation

- (id) initWithDelta:(KWDelta)delta {
    if (self = [super init]) {
        _elapsed = 0;
        _duration = 0;
        _delta = delta;
    }
    return self;
}

- (void) animate:(KWShape*)shape dt:(NSTimeInterval)dt {
    _elapsed += dt;
    
    if (_elapsed > _duration) {
        dt -= _elapsed - _duration;
    }
    
    KWDelta anim = shape.delta;
    
    CGFloat fractionOfDuration = dt / _duration;
    
    GLKVector2 positionIncrement = GLKVector2MultiplyScalar(_delta.position, fractionOfDuration);
    anim.position = GLKVector2Add(anim.position, positionIncrement);
        
    GLKVector2 scaleIncrement = GLKVector2MultiplyScalar(_delta.scale, fractionOfDuration);
    anim.scale = GLKVector2Add(anim.scale, scaleIncrement);
    
    anim.rotation += _delta.rotation * fractionOfDuration;
    
    GLKVector4 colorIncrement = GLKVector4MultiplyScalar(_delta.color, fractionOfDuration);
    anim.color = GLKVector4Add(anim.color, colorIncrement);
    
    shape.delta = anim;

}

@end
