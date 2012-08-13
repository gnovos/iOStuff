
#import "KWShape.h"

typedef struct {
    GLKVector2 position;
    GLKVector2 scale;
    CGFloat rotation;
    GLKVector4 color;
} KWDelta;

@interface KWAnimation : NSObject

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval elapsed;
@property (nonatomic, assign) KWDelta delta;

- (void) animateShape:(KWShape*)shape dt:(NSTimeInterval)dt;

@end
