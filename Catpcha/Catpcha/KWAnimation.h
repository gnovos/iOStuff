
#import "KWShape.h"

@interface KWAnimation : NSObject

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval elapsed;

//xxx delta object
@property (nonatomic, assign) GLKVector2 dpos;
@property (nonatomic, assign) GLKVector2 dscale;
@property (nonatomic, assign) CGFloat drot;
@property (nonatomic, assign) GLKVector4 dcolor;

- (void) animateShape:(KWShape*)shape dt:(NSTimeInterval)dt;

@end
