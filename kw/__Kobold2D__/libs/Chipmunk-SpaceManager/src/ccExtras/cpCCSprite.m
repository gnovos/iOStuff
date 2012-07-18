/*********************************************************************
 *	
 *	Chipmunk Sprite
 *
 *	cpSprite.m
 *
 *	Chipmunk Sprite Object
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 04/24/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cpCCSprite.h"


@implementation cpCCSprite

-(id) init
{
    [super init];
    
    _implementation = [[cpCCNodeImpl alloc] init];
    
    return self;
}


#define RENDER_IN_SUBPIXEL

-(void) draw
{
	cpShape *shape = _implementation.shape;
	if (shape && shape->CP_PRIVATE(klass)->type == CP_CIRCLE_SHAPE)
	{
		cpVect offset = cpCircleShapeGetOffset(shape);
		
		if (offset.x != 0 && offset.y != 0)
		{
			kmGLPushMatrix();

			// SI: ccglTranslate is no longer available
			CCLOG(@"%@: %@ method not converted to OpenGL ES 2.0", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
			/*
			ccglTranslate(RENDER_IN_SUBPIXEL(offset.x*CC_CONTENT_SCALE_FACTOR()), 
						  RENDER_IN_SUBPIXEL(offset.y*CC_CONTENT_SCALE_FACTOR()), 0);
			 */
			[super draw];
			kmGLPopMatrix();
		}
		else
			[super draw];
	}
	else
		[super draw];
}

CPCCNODE_FUNC_SRC

@end
