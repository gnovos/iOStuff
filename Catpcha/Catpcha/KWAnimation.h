
#import "KWShape.h"

@interface KWAnimation : NSObject

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval elapsed;
@property (nonatomic, assign) KWDelta delta;

- (id) initWithDelta:(KWDelta)dx;

- (void) animate:(KWShape*)shape dt:(NSTimeInterval)dt;

@end
