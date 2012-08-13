
#import "KWRectangle.h"

@implementation KWRectangle

- (id) initWithSize:(CGSize)size {
    if (self = [super init]) {
        [self.vertices append:GLKVector2Make( size.width/2.0f, -size.height/2.0f)];
        [self.vertices append:GLKVector2Make( size.width/2.0f,  size.height/2.0f)];
        [self.vertices append:GLKVector2Make(-size.width/2.0f,  size.height/2.0f)];
        [self.vertices append:GLKVector2Make(-size.width/2.0f, -size.height/2.0f)];
    }
    return self;
}

@end
