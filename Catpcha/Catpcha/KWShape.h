
#import "KWScene.h"
#import "KWSpriteAnimation.h"

@interface KWShape : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;
@property (nonatomic, assign, readonly) GLKVector2* vertices;
@property (nonatomic, assign, readonly) GLKVector4* vertexColors;
@property (nonatomic, assign, readonly) GLKVector2* textureCoordinates;
@property (nonatomic, assign) GLKVector4 color;
@property (nonatomic, assign) BOOL useConstantColor;
@property (nonatomic, assign) GLKVector2 position;
@property (nonatomic, assign) GLKVector2 velocity;
@property (nonatomic, assign) GLKVector2 acceleration;
@property (nonatomic, assign) GLKVector2 scale;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat angularVelocity;
@property (nonatomic, assign) CGFloat angularAcceleration;
@property (nonatomic, strong, readonly) NSMutableArray* children;
@property (nonatomic, weak) KWShape* parent;
@property (nonatomic, assign, readonly) GLKMatrix4 modelviewMatrix;
@property (nonatomic, strong, readonly) GLKTextureInfo* texture;
@property (nonatomic, strong, readonly) NSMutableArray* animations;
@property (nonatomic, strong) KWSpriteAnimation* spriteAnimation;

- (void) update:(NSTimeInterval)dt;
- (void) renderInScene:(KWScene*)scene;
- (void) setTextureImage:(UIImage*)image;
- (void) addChild:(KWShape*)child;
- (void) animateWithDuration:(NSTimeInterval)duration animations:(void(^)(void))animations;

@end