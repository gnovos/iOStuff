//
//  CALayer+KWMsg.h
//  Catpcha
//
//  Created by Mason on 8/2/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

@interface CALayer (KWMsg)

- (void) flash:(NSString*)message at:(CGPoint)loc;
- (void) hover:(NSString*)message over:(CGPoint)loc;

- (CATextLayer*) textlayer:(NSString*)message font:(UIFont*)font;

@end
