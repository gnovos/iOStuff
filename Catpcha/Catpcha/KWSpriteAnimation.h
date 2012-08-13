
@interface KWSpriteAnimation : NSObject

- (id) initWithTimePerFrame:(CGFloat)timePerFrame framesNamed:(NSArray*)names;
- (void) update:(NSTimeInterval)dt;
- (GLKTextureInfo*) frame;

@end
