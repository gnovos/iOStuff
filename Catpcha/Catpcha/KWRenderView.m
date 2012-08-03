//
//  KWRenderView.m
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWRenderView.h"
#import "KWObject.h"
#import "KWGFX.h"

@implementation KWRenderView 

@synthesize level;

- (id) initWithCoder:(NSCoder*)decoder { if (self = [super initWithCoder:decoder]) { [self setup]; } return self; }
- (id) initWithFrame:(CGRect)frame { if (self = [super initWithFrame:frame]) { [self setup]; } return self; }
- (void) setup {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
}

- (void) setLevel:(KWLevel*)lvl {
    level = lvl;
    [self reset];
}

- (void) reset {
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.layer addSublayer:self.level];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[event touchesForView:self] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *tstop) {
        CGPoint loc = [touch locationInView:self];        
        KWObject* obj = [[level touched:loc] lastObject];
        obj.touch = touch;
    }];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[event touchesForView:self] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *tstop) {
        [level.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *kstop) {
            if (o.touch == touch) {
                [KWGFX animate:^{ o.position = [touch locationInView:self]; }];
            }
        }];
    }];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {    
    [[event touchesForView:self] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *tstop) {
        [level.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *kstop) {
            if (o.touch == touch) {
                o.touch = nil;
                [KWGFX animate:^{ o.position = [touch locationInView:self]; }];
                [level capture:o];
            }
        }];
    }];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [[event touchesForView:self] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
        [level.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
            if (o.touch == touch) { o.touch = nil; }
        }];
    }];
}

@end
