
@interface KWSpriteAnimation : NSObject

- (id) initWithTimePerFrame:(CGFloat)timePerFrame framesNamed:(NSArray*)frameNames;
- (void) update:(NSTimeInterval)dt;
- (GLKTextureInfo*) currentFrame;

@end
