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
#import "NSObject+KW.h"

#define KWLevelScale 3.0f

#define KWMinZoom 1.0f / KWLevelScale
#define KWMaxZoom 5.0f

CGFloat CGPointDistanceBetween(CGPoint from, CGPoint to) {
    CGFloat dx = to.x - from.x;
    CGFloat dy = to.y - from.y;
    return hypot(dx, dy);
};

CGRect CGRectEnvelope(CGRect rect, CGPoint point) {
    
    if (CGRectIsNull(rect)) {
        rect.origin = point;
    } else {
        if (point.x < CGRectGetMinX(rect)) {
            CGFloat dw = CGRectGetMinX(rect) - point.x;
            rect.origin.x = point.x;
            rect.size.width += dw;
        } else if (point.x > CGRectGetMaxX(rect)) {
            rect.size.width += point.x - CGRectGetMaxX(rect);
        }
        if (point.y < CGRectGetMinY(rect)) {
            CGFloat dh = CGRectGetMinY(rect) - point.y;
            rect.origin.y = point.y;
            rect.size.height += dh;
        } else if (point.y > CGRectGetMaxY(rect)) {
            rect.size.width += point.y - CGRectGetMaxX(rect);
        }
    }
    
    return rect;
}


@interface KWTouch : NSObject
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGPoint touch;
@property (nonatomic, assign) CGFloat distance;

@end

@implementation KWTouch 

- (id) initWithTouch:(CGPoint)touch andCenter:(CGPoint)center {
    if (self = [super init]) {
        self.center = center;
        self.touch = touch;
        self.distance = CGPointDistanceBetween(center, self.touch);
    }
    return self;
}

@end

@implementation KWRenderView {
    NSMutableDictionary* tracking;
    NSMutableDictionary* paths;
    CGFloat zoom;
    CGFloat rotation;
}

@synthesize level;

+ (Class) layerClass { return [CAScrollLayer class]; }

- (id) initWithCoder:(NSCoder*)decoder { if (self = [super initWithCoder:decoder]) { [self setup]; } return self; }
- (id) initWithFrame:(CGRect)frame { if (self = [super initWithFrame:frame]) { [self setup]; } return self; }
- (void) setup {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    tracking = [[NSMutableDictionary alloc] init];
    paths = [[NSMutableDictionary alloc] init];
}

- (void) setLevel:(KWLevel*)lvl {
    level = lvl;
    CGRect frame = self.frame;
    frame.size.width *= KWLevelScale;
    frame.size.height *= KWLevelScale;
    level.frame = frame;
    level.position = self.center;
    [self reset];
}

- (CAScrollLayer*) scroll { return (CAScrollLayer*)self.layer; }

- (void) reset {
    self.layer.borderWidth = 3.0f;
    self.layer.borderColor = [UIColor redColor].CGColor;
    
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.layer addSublayer:self.level];
    
    self.level.borderWidth = 5.0f;
    self.level.borderColor = [UIColor greenColor].CGColor;    
}

- (NSSet*) tracked:(UIEvent*)event{
    return [[tracking objectForKey:[event ptr]] copy];
}

- (NSMutableDictionary*) path:(UIEvent*)event{
    NSMutableDictionary* path = [paths objectForKey:[event ptr]];
    if (path == nil) {
        path = [[NSMutableDictionary alloc] init];
        [paths setObject:path forKey:[event ptr]];
    }
    return path;
}

- (void) track:(UITouch*)touch forEvent:(UIEvent*)event {
    NSMutableSet* touches = [tracking objectForKey:[event ptr]];
    if (touches == nil) {
        touches= [[NSMutableSet alloc] init];
        [tracking setObject:touches forKey:[event ptr]];
    }
    
    [touches addObject:touch];    
}

- (void) untrack:(UITouch*)touch forEvent:(UIEvent*)event {
    NSMutableSet* touches = [tracking objectForKey:[event ptr]];
    if (touches) {
        [touches removeObject:touch];
        if (touches.count == 0) {
            [tracking removeObjectForKey:[event ptr]];
            [paths removeObjectForKey:[event ptr]];
        }
    }
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    NSMutableDictionary* path = [self path:event];
    
    __block CGPoint center = CGPointZero;
    __block int count = 0;
    
    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *tstop) {
        CGPoint loc = [touch locationInView:self];        
        KWObject* obj = [[level touched:loc] lastObject];
        if (obj) {
            obj.touch = touch;
        } else {
            [self track:touch forEvent:event];
            center.x += loc.x;
            center.y += loc.y;
            count++;
        }
    }];
    
    center.x /= count;
    center.y /= count;
    
    [[self tracked:event] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
        [path setObject:[[KWTouch alloc] initWithTouch:[touch locationInView:self] andCenter:center] forKey:[touch ptr]];
    }];
    
    zoom = [[self.layer valueForKeyPath:@"sublayerTransform.scale.x"] floatValue];
    rotation = [[self.layer valueForKeyPath:@"sublayerTransform.rotation.z"] floatValue];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    
    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *tstop) {
        __block BOOL used = NO;
        [level.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *kstop) {
            if (o.touch == touch) {
                [KWGFX animate:^{ o.position = [touch locationInView:self]; }];
                *kstop = used = YES;
            }
        }];
        
        if (used) {
            [self untrack:touch forEvent:event];
        }
    }];
    
    NSSet* tracked = [self tracked:event];
    if (tracked.count == 1) {
        UITouch* touch = tracked.anyObject;
        CGPoint prev = [touch previousLocationInView:self];
        CGPoint loc = [touch locationInView:self];
        
        CGPoint p = self.scroll.bounds.origin;
        
        p.x += prev.x - loc.x;
        p.y += prev.y - loc.y;
        
        [[self scroll] scrollToPoint:p];
        //xxx don't scroll past bounds
    } else {
        //zoom/rotate
                
        NSMutableDictionary* first = [self path:event];
        __block CGPoint center = CGPointZero;
        __block CGFloat origdist = 0.0f;
        [tracked enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
            CGPoint loc = [touch locationInView:self];
            KWTouch* ktouch = [first objectForKey:[touch ptr]];
            origdist += ktouch.distance;
                                                
            center.x += loc.x;
            center.y += loc.y;
        }];
        center.x /= tracked.count;
        center.y /= tracked.count;
        origdist /= tracked.count;
        
        __block CGFloat distance = 0.0f;
        __block CGFloat rot = 0.0f;
        __block CGFloat slope = 0.0f;
        [tracked enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
            CGPoint loc = [touch locationInView:self];
            distance += CGPointDistanceBetween(center, loc);

            KWTouch* ktouch = [first objectForKey:[touch ptr]];
            
            CGFloat a = CGPointDistanceBetween(ktouch.center, loc);
            CGFloat b = CGPointDistanceBetween(ktouch.center, ktouch.touch);
            CGFloat c = CGPointDistanceBetween(loc, ktouch.touch);
            
            CGFloat m = (loc.y - ktouch.touch.y) / (loc.x - ktouch.touch.x);
            slope += m > 0 ? 1 : -1;
            
            CGFloat angle = acosf((a * a + b * b - c * c) / (2 * a * b));
            
            NSLog(@"a:%f b:%f c:%f angle:%f m:%f", a, b, c, angle, m);
            
            rot += angle;
        }];
        distance /= tracked.count;
        rot /= tracked.count;
        slope /= tracked.count;
        
        CGFloat scale = MAX(KWMinZoom, MIN(KWMaxZoom, (distance / origdist) * zoom));
        
        if (slope < 0) { rot = -rot; }
        
        NSLog(@"r:%f rot:%f slope:%f", rotation, rot, slope);
                                
        //[self.layer setValue:[NSNumber numberWithFloat:rotation] forKeyPath:@"sublayerTransform.rotation"];
        //[self.layer setValue:[NSNumber numberWithFloat:scale] forKeyPath:@"sublayerTransform.scale.x"];
        //[self.layer setValue:[NSNumber numberWithFloat:scale] forKeyPath:@"sublayerTransform.scale.y"];
        
        CATransform3D xform = CATransform3DIdentity;
        xform = CATransform3DScale(xform, scale, scale, 1.0f);
        xform = CATransform3DRotate(xform, rotation + rot, 0.0f, 0.0f, 1.0f);
        self.layer.sublayerTransform = xform;
        
        NSLog(@"\n-=-=-\n\n");
        
    }
    
        
//    NSLog(@"[moving] %@\n%@\n%@\n%@\n\n-=-=-=-=-\n\n", tracking, touches, event.allTouches, event);
    
}

/*
 if (CGRectIsNull(current)) {
 current.origin.x = loc.x;
 current.origin.y = loc.y;
 } else {
 if (loc.x < CGRectGetMinX(current)){
 current.origin.x = loc.x;
 } else if (loc.x > CGRectGetMaxX(current)) {
 current.size.width = loc.x - current.origin.x;
 }
 
 if (loc.y < CGRectGetMinY(current)) {
 current.origin.y = loc.y;
 } else if (loc.y > CGRectGetMaxY(current)) {
 current.size.height = loc.y - current.origin.y;
 }
 }
 
 if (CGRectIsNull(last)) {
 last.origin.x = prev.x;
 last.origin.y = prev.y;
 } else {
 if (prev.x < CGRectGetMinX(last)){
 last.origin.x = prev.x;
 } else if (prev.x > CGRectGetMaxX(last)) {
 last.size.width = prev.x - last.origin.x;
 }
 
 if (prev.y < CGRectGetMinY(last)) {
 last.origin.y = prev.y;
 } else if (prev.y > CGRectGetMaxY(last)) {
 last.size.height = prev.y - last.origin.y;
 }
 }
 
 */

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *tstop) {
        [self untrack:touch forEvent:event];
        [level.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *kstop) {
            if (o.touch == touch) {
                o.touch = nil;
                [KWGFX animate:^{ o.position = [touch locationInView:self]; }];
                [level capture:o];
            }
        }];
    }];
//    NSLog(@"[end] %@\n%@\n%@\n%@\n\n-=-=-=-=-\n\n", tracking, touches, event.allTouches, event);
    
}

- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
        [self untrack:touch forEvent:event];
        [level.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
            if (o.touch == touch) { o.touch = nil; }
        }];
    }];
}

@end
