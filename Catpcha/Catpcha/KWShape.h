
#import "KWScene.h"
#import "KWVertex.h"

@interface KWShape : NSObject

@property (nonatomic, assign) GLKVector2 position;
@property (nonatomic, assign) GLKVector2 scale;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) GLKVector4 color;

- (id) initWithVertices:(KWVertex*)vdata;

- (void) setTextureImage:(UIImage*)image;

- (void) update:(NSTimeInterval)dt;
- (void) renderInScene:(KWScene*)scene;
- (void) addChild:(KWShape*)child;
- (void) animateWithDuration:(NSTimeInterval)duration animations:(void(^)(void))animations;

@end