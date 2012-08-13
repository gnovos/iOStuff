

#import "KWSprite.h"

@implementation KWSprite {
    NSMutableArray* frames;
    CGFloat timePerFrame;
    CGFloat elapsed;
}

- (id) initWithImage:(UIImage*)image pointRatio:(CGFloat)ratio {

    CGSize size = image.size;
    size.width /= ratio;
    size.height /= ratio;

    if (self = [super initWithSize:size]) {
        [self setTextureImage:image];
    }
    return self;
}

- (id) initWithTimePerFrame:(CGFloat)time framesNamed:(NSArray*)names {
    if (self = [super init]) {
        elapsed = 0;
        timePerFrame = time;
        frames = [NSMutableArray arrayWithCapacity:names.count];
        for (NSString* name in names) {
            [frames addObject:[GLKTextureLoader textureWithCGImage:[UIImage imageNamed:name].CGImage
                                                           options:@{ GLKTextureLoaderOriginBottomLeft: @YES }
                                                             error:NULL]];
        }
    }
    return self;
}

- (void) update:(NSTimeInterval)dt {
    [super update:dt];
    elapsed += dt;
}

- (GLKTextureInfo*) texture {
    if (frames.count) {
        //xxx use function that does this?
        //xxx use keyframiness stuff?
        NSInteger index = ((int)(elapsed / timePerFrame)) % frames.count;
        return [frames objectAtIndex:index];
    }
    return super.texture;
}


@end
