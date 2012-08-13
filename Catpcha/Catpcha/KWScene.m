#import "KWScene.h"
#import "KWShape.h"

@implementation KWScene {
    GLKVector4 clear;
    NSMutableArray* shapes;
}

- (id) init {
    if (self = [super init]) {
        clear  = GLKVector4Make(1,1,1,1);
        shapes = [[NSMutableArray alloc] init];
        self.projection = GLKMatrix4MakeOrtho(-3.0, 3.0f, -2.0f, 2.0f, 1.0f, -1.0f);
    }
    return self;
}

- (void) update:(NSTimeInterval)dt {
    [shapes enumerateObjectsUsingBlock:^(KWShape* shape, NSUInteger idx, BOOL *stop) {
        [shape update:dt];
    }];
}

- (void) render {
    glClearColor(clear.r, clear.g, clear.b, clear.a);
    glClear(GL_COLOR_BUFFER_BIT);
    [shapes enumerateObjectsUsingBlock:^(KWShape* shape, NSUInteger idx, BOOL *stop) {
        [shape renderInScene:self];
    }];
}

@end
