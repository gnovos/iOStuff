
#import "KWShape.h"

typedef struct {
    GLKVector2 position;
    GLKVector2 scale;
    CGFloat rotation;
    GLKVector4 color;
} KWDelta;

static inline KWDelta KWDeltaMake(GLKVector2 position, GLKVector2 scale, CGFloat rotation, GLKVector4 color) {
    KWDelta delta; delta.position = position; delta.scale = scale; delta.rotation = rotation; delta.color = color; 
    return delta;
}

@interface KWAnimation : NSObject

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval elapsed;
@property (nonatomic, assign) KWDelta delta;

- (void) animate:(KWShape*)shape dt:(NSTimeInterval)dt;

@end
