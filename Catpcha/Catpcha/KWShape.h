
#import "KWRenderer.h"
#import "KWGeometry.h"
#import "KWTexture.h"
#import "KWMoment.h"

@interface KWShape : NSObject

@property (nonatomic, strong, readonly) NSMutableArray* shapes;
@property (nonatomic, strong, readonly) KWGeometry* geometry;
@property (nonatomic, strong, readonly) KWMoment* moment;

- (id) initWithTexture:(KWTexture*)tex;

- (void) update:(NSTimeInterval)dt;
- (void) render:(GLKMatrix4)projection;

- (void) add:(KWShape*)child;
- (void) remove:(KWShape*)child;
- (void) removeAll;

@end