
#import "KWRenderer.h"
#import "KWVertex.h"
#import "KWTexture.h"

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

@interface KWShape : NSObject

@property (nonatomic, strong, readonly) KWVertex* vertices;
@property (nonatomic, assign) KWDelta delta;

- (id) initWithTexture:(KWTexture*)tex;

- (void) update:(NSTimeInterval)dt;
- (void) render;

- (void) add:(KWShape*)child;
- (void) remove:(KWShape*)child;

- (void) animateWithDuration:(NSTimeInterval)duration animations:(void(^)(void))animations;

@end