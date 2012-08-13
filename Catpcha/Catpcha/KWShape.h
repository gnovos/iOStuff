
#import "KWScene.h"
#import "KWVertex.h"
#import "KWTexture.h"

@interface KWShape : NSObject

@property (nonatomic, strong) KWVertex* vertices;
@property (nonatomic, assign) GLKVector2 position;
@property (nonatomic, assign) GLKVector2 scale;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) GLKVector4 color;

- (id) initWithTexture:(KWTexture*)tex;

- (void) update:(NSTimeInterval)dt;
- (void) render;

- (void) add:(KWShape*)child;
- (void) remove:(KWShape*)child;

- (void) animateWithDuration:(NSTimeInterval)duration animations:(void(^)(void))animations;

@end