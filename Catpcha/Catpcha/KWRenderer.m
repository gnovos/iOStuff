#import "KWRenderer.h"
#import "KWShape.h"

@implementation KWRenderer {    
    GLKVector4 clear;
    NSMutableArray* shapes;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    clear  = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    shapes = [[NSMutableArray alloc] init];

    GLKView* glview = (GLKView*)self.view;
    
    glview.delegate = self;
    //xxx set other formats
}

- (void) update {
    NSTimeInterval dt = self.timeSinceLastUpdate;
    [shapes enumerateObjectsUsingBlock:^(KWShape* shape, NSUInteger idx, BOOL *stop) {
        [shape update:dt];
    }];
}

- (void) glkView:(GLKView*)view drawInRect:(CGRect)rect {
    //xxx check rect?
    
    glClearColor(clear.r, clear.g, clear.b, clear.a);
    glClear(GL_COLOR_BUFFER_BIT);
    [shapes enumerateObjectsUsingBlock:^(KWShape* shape, NSUInteger idx, BOOL *stop) {
        [shape render];
    }];    
}

@end
