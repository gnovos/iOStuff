//
//  CALayer+KWMsg.m
//  Catpcha
//
//  Created by Mason on 8/2/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "CALayer+KWMsg.h"

@implementation CALayer (KWMsg)

- (UIFont*) font { return [UIFont systemFontOfSize:KWNoticeFontSize]; }

- (CATextLayer*) textlayer:(NSString*)message font:(UIFont*)font {
    CGSize bounds = [message sizeWithFont:font];
    
    CATextLayer* text = [[CATextLayer alloc] init];
    text.string = message;
    text.font = (__bridge CFTypeRef)(font.fontName);
    text.fontSize = font.pointSize;
    text.alignmentMode = @"center";
    text.frame = CGRectMake(KWNoticePadding, KWNoticePadding, bounds.width, bounds.height);
    text.foregroundColor = [UIColor darkTextColor].CGColor;
    return text;
}

- (CALayer*) popup:(NSString*)message {
    CATextLayer* text = [self textlayer:message font:[self font]];
    
    CGSize size = text.bounds.size;
    
    CALayer* popup = [[CALayer alloc] init];
    popup.opacity = 0.0f;
    
    popup.frame = CGRectMake(0, 0, size.width + (KWNoticePadding * 2), size.height + (KWNoticePadding * 2));
    
    popup.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.95f alpha:0.85f].CGColor;
    
    popup.shadowColor = [UIColor darkGrayColor].CGColor;
    popup.shadowOffset = CGSizeMake(0, 0);
    popup.shadowRadius = 3.0f;
    popup.shouldRasterize = YES;
    popup.shadowOpacity = 0.4f;
    
    popup.borderColor = [UIColor colorWithRed:1.0f green:0.6f blue:0.2f alpha:0.9f].CGColor;
    popup.borderWidth = 3.0f;
    
    popup.cornerRadius = 7.0f;
    
    [popup addSublayer:text];
    
    return popup;
}

- (void) hover:(NSString*)message over:(CGPoint)loc {
    
    CALayer* popup = [self popup:message];
    
    [KWGFX animate:KWHoverDuration animation:^{
        popup.position = loc;
        
        [self addSublayer:popup];
        
        CAAnimationGroup* group = [CAAnimationGroup animation];
        
        CAKeyframeAnimation* fade = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        fade.duration = KWHoverDuration;
        
        fade.values = @[@1.0f, @1.0f, @0.0f];
        fade.keyTimes = @[@0.0f, @0.8f, @1.0f];
        
        CAKeyframeAnimation *grow = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        grow.duration = 0.7f;
        
        grow.values = @[@0.0f, @1.4f, @0.7f, @1.0f];
        grow.keyTimes = @[@0.0f, @0.5f, @0.9f, @1.0f];
        grow.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        grow.fillMode = kCAFillModeForwards;
                                
        group.animations = @[fade, grow];
        
        [popup addAnimation:group forKey:@"hover"];
    } onComplete:^{
        [popup removeFromSuperlayer];
    }];    
    
}

- (void) flash:(NSString*)message at:(CGPoint)loc {
    
    CALayer* popup = [self popup:message];
        
    [KWGFX animate:KWFlashDuration animation:^{
        popup.position = loc;

        [self addSublayer:popup];
        
        CAAnimationGroup* group = [CAAnimationGroup animation];
        
        CABasicAnimation* fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fade.fromValue = @1.0f;
        fade.toValue = @0.0f;
        
        CABasicAnimation* grow = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        grow.fromValue = @1.0f;
        grow.toValue = @1.5f;
        
        group.animations = @[fade, grow];
        
        [popup addAnimation:group forKey:@"flash"];
    } onComplete:^{
        [popup removeFromSuperlayer];
    }];
    
}


@end
