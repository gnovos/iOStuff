
#import "KWScene.h"
#import "KWVertex.h"
#import "KWTexture.h"

@interface KWShape : NSObject

@property (nonatomic, strong, readonly) KWVertex* vertices;

@property (nonatomic, assign) GLKVector2 position;
@property (nonatomic, assign) GLKVector2 scale;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) GLKVector4 color;

- (id) initWithTexture:(KWTexture*)tex;

- (void) update:(NSTimeInterval)dt;
- (void) renderInScene:(KWScene*)scene;
- (void) addChild:(KWShape*)child;
- (void) animateWithDuration:(NSTimeInterval)duration animations:(void(^)(void))animations;

@end