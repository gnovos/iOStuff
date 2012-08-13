//
//  KWTexture.h
//  Catpcha
//
//  Created by Mason on 8/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWVertex.h"

@interface KWTexture : NSObject

@property (nonatomic, strong, readonly) KWVertex* vertices;
@property (nonatomic, strong, readonly) GLKTextureInfo* info;

@end
