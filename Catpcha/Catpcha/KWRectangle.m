
#import "KWRectangle.h"

@implementation KWRectangle

- (id) initWithSize:(CGSize)size {
    if (self = [super initWithVertices:[KWVertex build:^(KWVertex *vx) {
        [vx append:GLKVector2Make( size.width/2.0f, -size.height/2.0f)];
        [vx append:GLKVector2Make( size.width/2.0f,  size.height/2.0f)];
        [vx append:GLKVector2Make(-size.width/2.0f,  size.height/2.0f)];
        [vx append:GLKVector2Make(-size.width/2.0f, -size.height/2.0f)]; }]]) {
        
    }
    return self;
}

@end
