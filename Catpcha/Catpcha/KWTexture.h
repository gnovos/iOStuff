//
//  KWTexture.h
//  Catpcha
//
//  Created by Mason on 8/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWGeometry.h"

typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;
} TexturedQuad;

@interface KWTexture : NSObject

@property (nonatomic, strong, readonly) KWGeometry* geometry;
@property (nonatomic, strong, readonly) GLKTextureInfo* info;

@end
