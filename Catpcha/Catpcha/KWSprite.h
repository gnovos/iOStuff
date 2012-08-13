
#import "KWRectangle.h"

@interface KWSprite : KWRectangle

- (id) initWithImage:(UIImage*)image pointRatio:(CGFloat)ratio;

- (id) initWithTimePerFrame:(CGFloat)timePerFrame framesNamed:(NSArray*)names;


@end
