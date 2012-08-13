
#import "KWSpriteAnimation.h"

@implementation KWSpriteAnimation {
    NSArray *frames;
    CGFloat timePerFrame;
    CGFloat elapsedTime;
}

- (id) initWithTimePerFrame:(CGFloat)time framesNamed:(NSArray *)frameNames {
  if (self = [super init]) {
    elapsedTime = 0;
    timePerFrame = time;
    frames = [NSMutableArray arrayWithCapacity:[frameNames count]];
    for (NSString *name in frameNames)
      [(NSMutableArray*)frames addObject:
      [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:name].CGImage 
                                   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft] 
                                     error:nil]];
  }
  return self;
}

- (void) update:(NSTimeInterval)dt {
  elapsedTime += dt;
}

- (GLKTextureInfo*) currentFrame {
  return [frames objectAtIndex:((int)(elapsedTime/timePerFrame))%[frames count]];
}

@end
