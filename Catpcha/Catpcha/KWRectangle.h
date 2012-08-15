
#import "KWShape.h"

@interface KWRectangle : KWShape

@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, assign, readonly) CGRect bounds;

- (id) initWithTexture:(KWTexture*)texture andSize:(CGSize)size;

@end
