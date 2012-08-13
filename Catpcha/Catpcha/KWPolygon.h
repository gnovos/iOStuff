

#import "KWShape.h"

@interface KWPolygon : KWShape

- (id) initWithTexture:(KWTexture*)texture andSides:(NSUInteger)numSides withRadius:(CGFloat)radius;

@end
