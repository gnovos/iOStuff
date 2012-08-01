//
//  KWSign.m
//  Catpcha
//
//  Created by Mason on 8/1/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWBackground.h"
#import "KWLevel.h"

@implementation KWBackground {
    NSTimeInterval remaining;
}

- (id) initWithLevel:(KWLevel*)lvl andFrame:(CGRect)frame {
    if (self = [super initWithLevel:lvl andSize:frame.size]) {
        self.frame = frame;
    }
    return self;
}

- (BOOL) tick:(CGFloat)dt {
    
    [super tick:dt];
    
    return remaining - self.level.remaining > 1.0f;
    
}

- (void) drawInContext:(CGContextRef)ctx {
    KWGFX* gfx = [[KWGFX alloc] initWithContext:ctx];
        
    UIColor* stroke = [UIColor colorWithRed:0.5f green:0.5f blue:0.7f alpha:0.3f];
    remaining = self.level.remaining;
    float remain = (0.8f * (1.0f - (remaining / self.level.timelimit)));

    UIColor* fill = [UIColor colorWithRed:0.7f green:0.3f blue:0.3f alpha:0.2f + remain];
    if (remaining > 0) {
        NSString* text = [NSString stringWithFormat:@"Level %d (%d s)", self.level.level, (int)remaining];
        [[[[[[[gfx stroke:stroke] fill:fill] angle:-45.0f] mode:kCGTextFillStroke] font:@"Helvetica Bold" size:38.0f] x:67.0f y:345.0f] text:text];
    }
    
}


@end
