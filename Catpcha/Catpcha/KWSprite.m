

#import "KWSprite.h"

@implementation KWSprite

- (id) initWithImage:(UIImage*)image pointRatio:(CGFloat)ratio {
    if (self = [super init]) {
        CGSize size = image.size;
        size.width /= ratio;
        size.height /= ratio;
        
        self.size = size;
        
        [self setTextureImage:image];
        self.textureCoordinates[0] = GLKVector2Make(1,0);
        self.textureCoordinates[1] = GLKVector2Make(1,1);
        self.textureCoordinates[2] = GLKVector2Make(0,1);
        self.textureCoordinates[3] = GLKVector2Make(0,0);
    }
    return self;
}

@end
