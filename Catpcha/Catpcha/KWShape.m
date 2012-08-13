
#import "KWShape.h"
#import "KWAnimation.h"

@implementation KWShape {
    NSMutableData* vertexData;
    NSMutableData* vertexColorData;
    NSMutableData* textureCoordinateData;
}

@synthesize color,
useConstantColor,
position,
velocity,
acceleration,
rotation,
angularVelocity,
angularAcceleration,
scale,
children,
parent,
texture,
animations,
spriteAnimation;

- (id) init {
    if (self = [super init]) {
        useConstantColor = YES;
        color = GLKVector4Make(1,1,1,1);
        texture = nil;
        position = GLKVector2Make(0,0);
        rotation = 0;
        scale = GLKVector2Make(1,1);
        children = [[NSMutableArray alloc] init];
        animations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger) count { return 0; }

- (GLKVector2*) vertices {
    if (vertexData == nil) {
        vertexData = [NSMutableData dataWithLength:sizeof(GLKVector2) * self.count];
    }
    return [vertexData mutableBytes];
}

- (GLKVector4*) vertexColors {
    if (vertexColorData == nil) {
        vertexColorData = [NSMutableData dataWithLength:sizeof(GLKVector4) * self.count];
    }
    return [vertexColorData mutableBytes];
}

- (GLKVector2*) textureCoordinates {
    if (textureCoordinateData == nil) {
        textureCoordinateData = [NSMutableData dataWithLength:sizeof(GLKVector2) * self.count];
    }
    return [textureCoordinateData mutableBytes];
}

- (GLKMatrix4) modelviewMatrix {
    GLKMatrix4 modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(position.x, position.y, 0),
                                                    GLKMatrix4MakeRotation(rotation, 0, 0, 1));
    modelviewMatrix = GLKMatrix4Multiply(modelviewMatrix, GLKMatrix4MakeScale(scale.x, scale.y, 1));
    
    if (parent != nil) {
        modelviewMatrix = GLKMatrix4Multiply(parent.modelviewMatrix, modelviewMatrix);
    }
    
    return modelviewMatrix;
}

- (void) update:(NSTimeInterval)dt {
    angularVelocity += angularAcceleration * dt;
    rotation += angularVelocity * dt;
    
    GLKVector2 changeInVelocity = GLKVector2MultiplyScalar(self.acceleration, dt);
    self.velocity = GLKVector2Add(self.velocity, changeInVelocity);
    
    GLKVector2 distanceTraveled = GLKVector2MultiplyScalar(self.velocity, dt);
    self.position = GLKVector2Add(self.position, distanceTraveled);
    
    [animations enumerateObjectsUsingBlock:^(KWAnimation *animation, NSUInteger idx, BOOL *stop) {
        [animation animateShape:self dt:dt];
    }];
    
    [animations filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KWAnimation *animation, NSDictionary *bindings) {
        return animation.elapsed <= animation.duration;
    }]];
    
    [spriteAnimation update:dt];
}

- (void) renderInScene:(KWScene*)scene {
    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
    if (useConstantColor) {
        effect.useConstantColor = YES;
        effect.constantColor = self.color;
    }
    if (self.texture != nil) {
        effect.texture2d0.envMode = GLKTextureEnvModeReplace;
        effect.texture2d0.target = GLKTextureTarget2D;
        if (self.spriteAnimation != nil)
            effect.texture2d0.name = self.spriteAnimation.frame.name;
        else
            effect.texture2d0.name = self.texture.name;
    }
    
    effect.transform.modelviewMatrix = self.modelviewMatrix;
    effect.transform.projectionMatrix = scene.projection;
    [effect prepareToDraw];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, self.vertices);
    
    if (!useConstantColor) {
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, self.vertexColors);
    }
    
    if (texture != nil) {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, self.textureCoordinates);
    }
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, self.count);
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    if (!useConstantColor) {
        glDisableVertexAttribArray(GLKVertexAttribColor);
    }
    
    if (self.texture != nil) {
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
    
    glDisable(GL_BLEND);
    
    [children enumerateObjectsUsingBlock:^(KWShape* shape, NSUInteger idx, BOOL *stop) {
        [shape renderInScene:scene];
    }];
}

- (void) setTextureImage:(UIImage*)image {
    NSError* error;
    texture = [GLKTextureLoader textureWithCGImage:image.CGImage options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft] error:&error];
    elog(error);
}

- (void) addChild:(KWShape*)child {
    child.parent = self;
    [children addObject:child];
}

- (void) animateWithDuration:(NSTimeInterval)duration animations:(void(^)(void))animationsBlock {
    GLKVector2 currentPosition = self.position;
    GLKVector2 currentScale = self.scale;
    GLKVector4 currentColor = self.color;
    CGFloat currentRotation = self.rotation;
    
    animationsBlock();
    
    KWAnimation *animation = [[KWAnimation alloc] init];
    animation.delta = (KWDelta) {
        GLKVector2Subtract(self.position, currentPosition),
        GLKVector2Subtract(self.scale, currentScale),
        self.rotation - currentRotation,
        GLKVector4Subtract(self.color, currentColor)
    };
    
    animation.duration = duration;
    [self.animations addObject:animation];
    
    self.position = currentPosition;
    self.scale = currentScale;
    self.color = currentColor;
    self.rotation = currentRotation;
}

@end
