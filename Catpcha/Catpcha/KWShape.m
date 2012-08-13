
#import "KWShape.h"
#import "KWAnimation.h"

static GLKMatrix4 projection;

@interface KWShape ()

@property (nonatomic, weak) KWShape* parent;
@property (nonatomic, strong) NSMutableArray* children;
@property (nonatomic, assign) GLKMatrix4 matrix;

@end

@implementation KWShape {
   
    GLKBaseEffect* effect;
    KWTexture* texture;
    
    NSMutableArray* animations;
            
    GLKVector2 velocity;
    GLKVector2 acceleration;
    
    CGFloat angularVelocity;
    CGFloat angularAcceleration;
}

- (id) initWithTexture:(KWTexture*)tex {
    if (self = [super init]) {
        
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            projection = GLKMatrix4MakeOrtho(-3.0, 3.0f, -2.0f, 2.0f, 1.0f, -1.0f);
        });
        
        self.children = [[NSMutableArray alloc] init];
        self.vertices = [[KWVertex alloc] init];

        animations = [[NSMutableArray alloc] init];
        
        texture = tex;
        
        self.position = GLKVector2Make(0,0);
        self.scale = GLKVector2Make(1,1);
        self.rotation = 0;
        self.color = GLKVector4Make(1,1,1,1);
                
        [self updateMatrix];
        
    }
    return self;
}

- (void) setParent:(KWShape*)parent {
    _parent = parent;
    [self updateMatrix];
}

- (void) setPosition:(GLKVector2)position {
    _position = position;
    [self updateMatrix];
}

- (void) setRotation:(CGFloat)rotation {
    _rotation = rotation;
    [self updateMatrix];
}

- (void) setScale:(GLKVector2)scale {
    _scale = scale;
    [self updateMatrix];
}

- (void) updateMatrix {
    
    GLKMatrix4 matrix = GLKMatrix4MakeTranslation(self.position.x, self.position.y, 0);

    matrix = GLKMatrix4Multiply(matrix, GLKMatrix4MakeRotation(self.rotation, 0, 0, 1));
    matrix = GLKMatrix4Multiply(matrix, GLKMatrix4MakeScale(self.scale.x, self.scale.y, 1));
    
    if (self.parent) {
        matrix = GLKMatrix4Multiply(self.parent.matrix, matrix);
    }
    
    self.matrix = matrix;
    
    effect = [[GLKBaseEffect alloc] init];
    if (texture) {
        effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        effect.texture2d0.target = GLKTextureTarget2D;
        effect.texture2d0.name = texture.info.name;
    } else {
        effect.useConstantColor = YES;
        effect.constantColor = self.color;
    }
    
    effect.transform.modelviewMatrix = self.matrix;
    effect.transform.projectionMatrix = projection;
    
    [effect prepareToDraw];

    
    [[self.children copy] enumerateObjectsUsingBlock:^(KWShape* child, NSUInteger idx, BOOL *stop) {
        [child updateMatrix];
    }];
}

- (void) update:(NSTimeInterval)dt {
    
    angularVelocity += angularAcceleration * dt;
    self.rotation += angularVelocity * dt;
    
    GLKVector2 changeInVelocity = GLKVector2MultiplyScalar(acceleration, dt);
    velocity = GLKVector2Add(velocity, changeInVelocity);
    
    GLKVector2 distanceTraveled = GLKVector2MultiplyScalar(velocity, dt);
    self.position = GLKVector2Add(self.position, distanceTraveled);
    
    [animations enumerateObjectsUsingBlock:^(KWAnimation *animation, NSUInteger idx, BOOL *stop) {
        [animation animate:self dt:dt];
    }];
    
    [animations filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KWAnimation *animation, NSDictionary *bindings) {
        return animation.elapsed <= animation.duration;
    }]];
}

- (void) render {
        
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, self.vertices.data);
    
    if (texture) {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, texture.vertices.data);
    }
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, self.vertices.count);
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    if (texture) {
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
    
    glDisable(GL_BLEND);
    
    [[self.children copy] enumerateObjectsUsingBlock:^(KWShape* shape, NSUInteger idx, BOOL *stop) {
        [shape render];
    }];
}

- (void) add:(KWShape*)child {
    if (child.parent) {
        [child.parent remove:child];
    }
    child.parent = self;
    [self.children addObject:child];
}

- (void) remove:(KWShape*)child {
    [child.parent.children removeObject:child];
    child.parent = nil;
}

- (void) animateWithDuration:(NSTimeInterval)duration animations:(void(^)(void))animationsBlock {
    GLKVector2 currentPosition = self.position;
    GLKVector2 currentScale = self.scale;
    GLKVector4 currentColor = self.color;
    CGFloat currentRotation = self.rotation;
    
    animationsBlock();
    
    KWAnimation *animation = [[KWAnimation alloc] init];
    animation.delta = KWDeltaMake(
        GLKVector2Subtract(self.position, currentPosition),
        GLKVector2Subtract(self.scale, currentScale),
        self.rotation - currentRotation,
        GLKVector4Subtract(self.color, currentColor)
    );
    
    animation.duration = duration;
    [animations addObject:animation];
    
    self.position = currentPosition;
    self.scale = currentScale;
    self.color = currentColor;
    self.rotation = currentRotation;
}

@end
