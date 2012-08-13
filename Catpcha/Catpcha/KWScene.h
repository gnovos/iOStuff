
@interface KWScene : NSObject

@property (nonatomic, assign) GLKMatrix4 projection;

- (void) update:(NSTimeInterval)dt;
- (void) render;

@end
