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
