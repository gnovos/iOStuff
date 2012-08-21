//
//  KWTexture.m
//  Catpcha
//
//  Created by Mason on 8/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWTexture.h"

@implementation KWTexture {
    NSDictionary* map;
}

- (id) initWithImage:(UIImage*)image andMap:(NSDictionary*)texmap {
    if (self = [super init]) {
        map = texmap;
        
        NSError* error;
        _info = [GLKTextureLoader textureWithCGImage:image.CGImage
                                               options:@{GLKTextureLoaderOriginBottomLeft : @YES}
                                                 error:&error];
        elog(error);
        
        _geometry = [[KWGeometry alloc] initWithBlock:^(KWGeometry *vx) {
            [vx vertex:GLKVector2Make(1.0f, 0.0f)];
            [vx vertex:GLKVector2Make(1.0f, 1.0f)];
            [vx vertex:GLKVector2Make(0.0f, 1.0f)];
            [vx vertex:GLKVector2Make(0.0f, 0.0f)];
        }];
    }
    return self;
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	NSUInteger				width,
    height,
    i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	UIFont *				font;
	
	font = [UIFont fontWithName:name size:size];
	
	width = dimensions.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
            i *= 2;
		width = i;
	}
	height = dimensions.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
            i *= 2;
		height = i;
	}
	
	colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(height, width);
	context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	
	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
    [string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	UIGraphicsPopContext();
	
//xxxz	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_A8 pixelsWide:width pixelsHigh:height contentSize:dimensions];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}


/*
 CGSize size = image.size;
 size.width /= ratio;
 size.height /= ratio;
 
 CGFloat timePerFrame;
 CGFloat elapsed;
 
 - (void) update:(NSTimeInterval)dt {
 [super update:dt];
 elapsed += dt;
 }
 
 - (GLKTextureInfo*) texture {
 if (frames.count) {
 //xxx use function that does this?
 //xxx use keyframiness stuff?
 NSInteger index = ((int)(elapsed / timePerFrame)) % frames.count;
 return [frames objectAtIndex:index];
 }
 return super.texture;
 }
 
 */


@end
