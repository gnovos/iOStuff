
#import "KWSpriteAnimation.h"

@implementation KWSpriteAnimation {
    NSMutableArray* frames;
    CGFloat timePerFrame;
    CGFloat elapsed;
}

- (id) initWithTimePerFrame:(CGFloat)time framesNamed:(NSArray*)names {
    if (self = [super init]) {
        elapsed = 0;
        timePerFrame = time;
        frames = [NSMutableArray arrayWithCapacity:[names count]];
        for (NSString* name in names) {
            [frames addObject:[GLKTextureLoader textureWithCGImage:[UIImage imageNamed:name].CGImage
                                                           options:@{ GLKTextureLoaderOriginBottomLeft: @YES }
                                                             error:NULL]];
        }
    }
    return self;
}

- (void) update:(NSTimeInterval)dt { elapsed += dt; }

- (GLKTextureInfo*) frame {
    NSInteger index = ((int)(elapsed/timePerFrame)) % [frames count];
    return [frames objectAtIndex:index];
}

@end
