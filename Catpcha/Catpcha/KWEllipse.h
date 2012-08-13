

#import "KWShape.h"

@interface KWEllipse : KWShape

- (id) initWithTexture:(KWTexture*)texture andRadius:(CGPoint)radius;
- (id) initWithTexture:(KWTexture*)texture andRadius:(CGPoint)radius atResolution:(NSUInteger)resolution;

@end
