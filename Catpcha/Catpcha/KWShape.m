
#import "KWShape.h"

static GLKBaseEffect* texeffect;
static GLKBaseEffect* coeffect;
static GLKBaseEffect* vxeffect;

@interface KWShape ()

@property (nonatomic, weak) KWShape* parent;
@property (nonatomic, strong) NSMutableArray* shapes;

@end

@implementation KWShape {
    KWTexture* texture;    
}

+(void)initialize {
    texeffect = [[GLKBaseEffect alloc] init];
    texeffect.texture2d0.envMode = GLKTextureEnvModeReplace;
    texeffect.texture2d0.target  = GLKTextureTarget2D;

    coeffect  = [[GLKBaseEffect alloc] init];
    coeffect.useConstantColor = YES;
    
    vxeffect  = [[GLKBaseEffect alloc] init];

}

- (id) initWithTexture:(KWTexture*)tex {
    if (self = [super init]) {        
        texture = tex;
        _shapes = [[NSMutableArray alloc] init];
        _geometry = [[KWGeometry alloc] init];
        _moment = [[KWMoment alloc] init];
    }
    return self;
}

- (void) setParent:(KWShape*)parent {
    [self.parent remove:self];
    _parent = parent;
}

- (GLKMatrix4) matrix {
    KWMoment* delta = self.moment;

    GLKMatrix4 matrix = GLKMatrix4MakeTranslation(delta.position.x, delta.position.y, 0);
    matrix = GLKMatrix4Multiply(matrix, GLKMatrix4MakeRotation(delta.rotation, 0, 0, 1));
    matrix = GLKMatrix4Multiply(matrix, GLKMatrix4MakeScale(delta.scale.x, delta.scale.y, 1));
    
    if (self.parent) {
        matrix = GLKMatrix4Multiply(self.parent.matrix, matrix);
    }
    return matrix;
}

- (void) update:(NSTimeInterval)dt {
    
    KWMoment* delta = self.moment;
    
    delta.omega += delta.alpha * dt;
    delta.rotation += delta.omega * dt;
    
    GLKVector2 changeInVelocity = GLKVector2MultiplyScalar(delta.acceleration, dt);
    delta.velocity = GLKVector2Add(delta.velocity, changeInVelocity);
    
    GLKVector2 distanceTraveled = GLKVector2MultiplyScalar(delta.velocity, dt);
    delta.position = GLKVector2Add(delta.position, distanceTraveled);
        
}

- (void) prepare:(GLKMatrix4)projection {
    
    GLKBaseEffect* effect;
    
    if (texture) {        
        texeffect.texture2d0.name = texture.info.name;
        effect = texeffect;
    } else if (self.geometry.ccount) {
        effect = vxeffect;
    } else {
        coeffect.constantColor = self.moment.color;
        effect = coeffect;
    }
    
    effect.transform.modelviewMatrix = self.matrix;
    effect.transform.projectionMatrix = projection;

    [effect prepareToDraw];
}

//xxx batch renders
- (void) render:(GLKMatrix4)projection {
    [self prepare:projection];
        
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, self.geometry.vertices);
    
    BOOL vcolors = self.geometry.ccount > 0;
    
    if (vcolors) {
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, self.geometry.colors);
    }
    
    if (texture) {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, texture.geometry.vertices);
    }
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, self.geometry.vcount);
    
    if (texture) {
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }

    if (vcolors) {
        glDisableVertexAttribArray(GLKVertexAttribColor);
    }
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
        
    glDisable(GL_BLEND);
    
    [[self.shapes copy] enumerateObjectsUsingBlock:^(KWShape* shape, NSUInteger idx, BOOL *stop) {
        //xxx check if in visible rect?
        [shape render:projection];
    }];
}

- (void) add:(KWShape*)child {
    child.parent = self;
    [self.shapes addObject:child];
}

- (void) remove:(KWShape*)child {
    [child.parent.shapes removeObject:child];
    child.parent = nil;
}

- (void) removeAll {
    [[self.shapes copy] enumerateObjectsUsingBlock:^(KWShape* shape, NSUInteger idx, BOOL *stop) {
        [self remove:shape];
    }];
}

@end
