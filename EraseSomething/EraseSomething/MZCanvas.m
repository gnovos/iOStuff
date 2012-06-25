//
//  MZCanvas.m
//  EraseSomething
//
//  Created by Mason on 6/22/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZCanvas.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@implementation MZCanvas {

	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *context;
	
	GLuint renderBuffer, frameBuffer;
	
	GLuint	brush;
	CGPoint	location;
	CGPoint	previousLocation;
	BOOL	firstTouch;
    
}

+ (Class) layerClass { return [CAEAGLLayer class]; }

- (void) setup {
    
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                    nil];
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!context || ![EAGLContext setCurrentContext:context]) {
        @throw @"Failed to create graphics context";
    }
    
    CGImageRef brushImage = [UIImage imageNamed:@"smoke_brush"].CGImage;
    
    size_t width = CGImageGetWidth(brushImage);
    size_t height = CGImageGetHeight(brushImage);
    
    GLubyte* brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
    CGContextRelease(brushContext);
    glGenTextures(1, &brush);
    glBindTexture(GL_TEXTURE_2D, brush);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
    free(brushData);
    
    glMatrixMode(GL_PROJECTION);
    CGRect frame = self.bounds;
    glOrthof(0, frame.size.width, 0, frame.size.height, -1, 1);
    glViewport(0, 0, frame.size.width, frame.size.height);
    glMatrixMode(GL_MODELVIEW);
    
    glDisable(GL_DITHER);
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnable(GL_POINT_SPRITE_OES);
    glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
    glPointSize(width);
            
 	glColor4f(0.0,0,0,0.5);
    
}

- (void) layoutSubviews {
    
	[EAGLContext setCurrentContext:context];
	[self createFramebuffer];
	    
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, frameBuffer);
    
    glClearColor(0, 0.4, 0.2, 0.8);
    glClear(GL_COLOR_BUFFER_BIT);
    
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderBuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
}

- (BOOL) createFramebuffer {
        
	glDeleteFramebuffersOES(1, &frameBuffer);
	frameBuffer = 0;
	glDeleteRenderbuffersOES(1, &renderBuffer);
	renderBuffer = 0;	
    
	glGenFramebuffersOES(1, &frameBuffer);
	glGenRenderbuffersOES(1, &renderBuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, frameBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderBuffer);

	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderBuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
		
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

- (void) dealloc {
	if (brush) { glDeleteTextures(1, &brush); }
	if ([EAGLContext currentContext] == context) { [EAGLContext setCurrentContext:nil]; }
}

- (void) renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end {
	static GLfloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0, count;
	
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, frameBuffer);
	        
	if (vertexBuffer == NULL) {
		vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
    }
	
    int step = 3;
    
	count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / step), 1);
	for(int i = 0; i < count; ++i) {
		if(vertexCount == vertexMax) {
			vertexMax = 2 * vertexMax;
			vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
		}
		
		vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
		vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
		vertexCount += 1;
	}
	
	glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
	glDrawArrays(GL_POINTS, 0, vertexCount);
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderBuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGRect				bounds = [self bounds];
    UITouch*	touch = [[event touchesForView:self] anyObject];
	firstTouch = YES;
	location = [touch locationInView:self];
	location.y = bounds.size.height - location.y;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {  
    
	CGRect				bounds = [self bounds];
	UITouch*			touch = [[event touchesForView:self] anyObject];
    
	if (firstTouch) {
		firstTouch = NO;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
	} else {
		location = [touch locationInView:self];
	    location.y = bounds.size.height - location.y;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
	}
    
	[self renderLineFromPoint:previousLocation toPoint:location];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGRect				bounds = [self bounds];
    UITouch*	touch = [[event touchesForView:self] anyObject];
	if (firstTouch) {
		firstTouch = NO;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
		[self renderLineFromPoint:previousLocation toPoint:location];
	}        
}

- (void) setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    
	glColor4f(red	* alpha,
			  green * alpha,
			  blue	* alpha,
			  alpha);
}

@end
