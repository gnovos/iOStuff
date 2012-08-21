//
//  KWRenderer.m
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWRenderer.h"
#import "KWShape.h"
#import "KWObject.h"
#import "KWGFX.h"
#import "NSObject+KW.h"
#import <CoreMotion/CoreMotion.h>
#import "KWAlert.h"
#import "KWEngine.h"
#import "CALayer+KWMsg.h"

#import "KWRectangle.h"
#import "KWEllipse.h"

#define KWLevelScale 2.5f

#define KWMinZoom 1.0f / KWLevelScale
#define KWMaxZoom KWLevelScale

@interface KWTouch : NSObject
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGPoint touch;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) NSTimeInterval timestamp;
@end

@implementation KWTouch

- (id) initWithTouch:(UITouch*)touch andCenter:(CGPoint)center {
    if (self = [super init]) {
        self.center = center;
        self.touch = [touch locationInView:touch.view];
        self.distance = CGLineDistance((CGLine){center, self.touch});
        self.timestamp = touch.timestamp;
    }
    return self;
}

@end

typedef struct {
    CGPoint location;
    CGPoint velocity;
    NSTimeInterval timestamp;
} KWScroller;

typedef enum {
    KWScrollEdgeNone,
    KWScrollEdgeTop,
    KWScrollEdgeTopRight,
    KWScrollEdgeRight,
    KWScrollEdgeBottomRight,
    KWScrollEdgeBottom,
    KWScrollEdgeBottomLeft,
    KWScrollEdgeLeft,
    KWScrollEdgeTopLeft
} KWScrollEdge;


@interface KWRenderer ()

@end

@implementation KWRenderer {
    EAGLContext* context;
    
    KWEngine* engine;
    GLKVector4 clear;
    NSMutableArray* shapes;
    
    NSMutableDictionary* tracking;
    NSMutableDictionary* paths;
    CGFloat zoom;
    
    KWScroller scroller;
    CMMotionManager *motion;
    
    GLKMatrix4 projection;
    
    CGRect bounds;
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [engine pause];
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [engine unpause];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    GLKView* glview = (GLKView*)self.view;
    glview.context = context;
    
    CGRect screen = UIScreen.mainScreen.bounds;
    float aspect = screen.size.height / screen.size.width;
    projection = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -1.0f * aspect, 1.0f * aspect, 1.0f, -1.0f);
    bounds = CGRectMake(-1.0f, -1.0f, 2.0f, 2.0f * aspect);

    clear  = GLKVector4Make(KWRandomPercent, KWRandomPercent, KWRandomPercent, 1.0f);
    shapes = [[NSMutableArray alloc] init];
    
    tracking = [[NSMutableDictionary alloc] init];
    paths = [[NSMutableDictionary alloc] init];
        
    glview.delegate = self;
    //xxx set other formats
    
    engine = [[KWEngine alloc] init];
        
    [engine attach:self forEvent:KWEngineEventLevelComplete withHandler:^(UIViewController* game, KWLevel* level) {
        NSString* msg = level.solved ? @"Way to go, you failed to fail!" : @"Wow, you suck...";
        [self.view.layer hover:msg over:self.view.center];
    }];
    
    [engine attach:self forEvent:KWEngineEventLevelBegin withHandler:^(KWRenderer* rend, KWLevel* level) {
        [rend reset];
    }];
    
    [engine attach:self forEvent:KWEngineEventTick withHandler:^(KWRenderer* rend, NSNumber* dt) {
        [rend tick:[dt floatValue]];
    }];
    
    motion = [[CMMotionManager alloc] init];
    
    //xxx figure this out later
    //    if (motion.isDeviceMotionAvailable) {
    //		motion.deviceMotionUpdateInterval = 1.0f / 4.0f;
    //        [motion startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion* move, NSError* error) {
    //            if (ABS(move.userAcceleration.x) > 0.5 || ABS(move.userAcceleration.y) > 0.5) {
    //                [renderer addVelocity:CGPointMake(move.userAcceleration.x, move.userAcceleration.y)];
    //            }
    //
    //            CMAttitude* attitude = move.attitude;
    //            engine.level.bias = CGPointMake(attitude.roll, attitude.pitch);
    //         }];
    //    }
    //[engine start:YES];
    
    //xxx remove this later
    KWLevel* level = [[KWLevel alloc] initLevel:1 withSize:CGSizeMake(bounds.size.width * 0.9f, bounds.size.height * 0.9f)];
    
    [level populate];
        
    [shapes addObject:level];
    
    
}

- (void) update {
    NSTimeInterval dt = self.timeSinceLastUpdate;
    [shapes enumerateObjectsUsingBlock:^(KWShape* shape, NSUInteger idx, BOOL *stop) {
        [shape update:dt];
    }];
}

- (void) glkView:(GLKView*)view drawInRect:(CGRect)rect {
    //xxx check rect?
    glClearColor(clear.r, clear.g, clear.b, clear.a);
    glClear(GL_COLOR_BUFFER_BIT);
    [shapes enumerateObjectsUsingBlock:^(KWShape* shape, NSUInteger idx, BOOL *stop) {
        [shape render:projection];
    }];
}

- (void) reset {
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width *= KWLevelScale;
    frame.size.height *= KWLevelScale;
    
//xxxz    engine.level.frame = frame;
    
    //xxx
//    [[self.scroll sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//    [self.scroll addSublayer:engine.level];
//    
//    KWObject* basket = [engine.level.baskets lastObject];
//    CGPoint p = basket.position;
//    p.x -= self.scroll.bounds.size.width / 2.0f;
//    p.y -= self.scroll.bounds.size.height / 2.0f;
//    [self scrollTo:(CGRect){ p, basket.bounds.size }];
}

- (KWScrollEdge) scrollTo:(CGRect)visible {
    
    return KWScrollEdgeNone;
    
    //xxx how to move the camera around?
    
//    CGRect q = [engine.level convertRect:visible fromLayer:self.scroll];
//    
//    BOOL top = NO, bottom = NO, left = NO, right = NO;
//    
//    CGFloat padding = 200.0f;
//    
//    if (q.origin.x < -padding) {
//        q.origin.x = -padding;
//        left = YES;
//    }
//    
//    if (q.origin.y < -padding) {
//        q.origin.y = -padding;
//        top = YES;
//    }
//    
//    if (q.origin.x + q.size.width > self.level.bounds.size.width + padding) {
//        q.origin.x = self.level.bounds.size.width + padding - q.size.width;
//        right = YES;
//    }
//    
//    if (q.origin.y + q.size.height > self.level.bounds.size.height + padding) {
//        q.origin.y = self.level.bounds.size.height + padding - q.size.height;
//        bottom = YES;
//    }
//    
//    CGPoint p = [self.scroll convertPoint:q.origin fromLayer:self.level];
//    
//    [KWGFX animate:^{
//        [self.scroll scrollToPoint:p];
//    }];
//    
//    KWScrollEdge strike = KWScrollEdgeNone;
//    
//    if (top && left) {
//        strike = KWScrollEdgeTopLeft;
//    } else if (top && right) {
//        strike = KWScrollEdgeTopRight;
//    } else if (bottom & left) {
//        strike = KWScrollEdgeBottomLeft;
//    } else if (bottom & right) {
//        strike = KWScrollEdgeBottomRight;
//    } else if (top) {
//        strike = KWScrollEdgeTop;
//    } else if (bottom) {
//        strike = KWScrollEdgeBottom;
//    } else if (left) {
//        strike = KWScrollEdgeLeft;
//    } else if (right) {
//        strike = KWScrollEdgeRight;
//    }
//    return strike;
}

//xxx
//- (void) zoom:(CGFloat)zx {
//    CGFloat scale = MAX(KWMinZoom, MIN(KWMaxZoom, zx));
//    self.scroll.sublayerTransform = CATransform3DMakeScale(scale, scale, 1.0f);
//    [self scrollTo:self.scroll.bounds];
//}

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

//xxx
//- (void) addVelocity:(CGPoint)v {
//    //xxx
//    NSLog(@"addv %@", NSStringFromCGPoint(v));
//    CGRect bounds = self.scroll.bounds;
//    bounds.origin.x += v.x * 100.0f;
//    bounds.origin.y += v.y * 100.0f;
//    [self scrollTo:bounds];
//}

- (void) tick:(CGFloat)dt {
    
    //xxx
//    if (scroller.timestamp && !CGPointEqualToPoint(CGPointZero, scroller.velocity)) {
//        CGRect bounds = self.scroll.bounds;
//        bounds.origin.x += scroller.velocity.x * dt;
//        bounds.origin.y += scroller.velocity.y * dt;
//        
//        CGFloat multiplier = 1.5f;
//        
//        scroller.velocity.x -= scroller.velocity.x * dt * multiplier;
//        scroller.velocity.y -= scroller.velocity.y * dt * multiplier;
//        
//        if (ABS(scroller.velocity.x) < 3.0f) { scroller.velocity.x = 0.0f; }
//        if (ABS(scroller.velocity.y) < 3.0f) { scroller.velocity.y = 0.0f; }
//        
//        if (scroller.velocity.x == 0 && scroller.velocity.y == 0) {
//            scroller.timestamp = 0;
//        }
//        
//        CGFloat bounce = -0.35f;
//        KWScrollEdge hit = [self scrollTo:bounds];
//        switch (hit) {
//            case KWScrollEdgeBottom:
//            case KWScrollEdgeTop:
//                scroller.velocity.y *= bounce;
//                break;
//            case KWScrollEdgeLeft:
//            case KWScrollEdgeRight:
//                scroller.velocity.x *= bounce;
//                break;
//            case KWScrollEdgeTopRight:
//            case KWScrollEdgeBottomRight:
//            case KWScrollEdgeBottomLeft:
//            case KWScrollEdgeTopLeft:
//                scroller.velocity.x *= bounce;
//                scroller.velocity.y *= bounce;
//                break;
//                
//            default:
//                break;
//        }
//        
//    }
    
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    NSLog(@"t:%@ e:%@", touches, event);
    
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLocation = CGPointMake(touchLocation.x, 320 - touchLocation.y);
    
    
    
//    NSMutableDictionary* path = [self path:event];
//    
//    __block CGPoint center = CGPointZero;
//    __block int count = 0;
//    
//    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *tstop) {
//        CGPoint loc = [engine.level convertPoint:[touch locationInView:touch.view] fromLayer:self.scroll];
//        
//        KWObject* obj = [[engine.level touched:loc] lastObject];
//        if (obj) {
//            obj.touch = touch;
//        } else {
//            [self track:touch forEvent:event];
//            center.x += loc.x;
//            center.y += loc.y;
//            count++;
//        }
//    }];
//    
//    center.x /= count;
//    center.y /= count;
//    
//    NSSet* tracked = [self tracked:event];
//    if (tracked.count == 1) {
//        scroller.location = self.scroll.bounds.origin;
//        scroller.timestamp = event.timestamp;
//        scroller.velocity = CGPointZero;
//    }
//    
//    [tracked enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
//        [path setObject:[[KWTouch alloc] initWithTouch:touch andCenter:center] forKey:[touch ptr]];
//    }];
//    
//    zoom = [[self.scroll valueForKeyPath:@"sublayerTransform.scale.x"] floatValue];
}
//
//- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
//    
//    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *tstop) {
//        __block BOOL used = NO;
//        [engine.level.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *kstop) {
//            if (o.touch == touch) {
//                [KWGFX animate:^{ o.position = [engine.level convertPoint:[touch locationInView:touch.view] fromLayer:self.scroll]; }];
//                *kstop = used = YES;
//            }
//        }];
//        
//        if (used) {
//            [self untrack:touch forEvent:event];
//        }
//    }];
//    
//    NSSet* tracked = [self tracked:event];
//    if (tracked.count == 1) {
//        UITouch* touch = tracked.anyObject;
//        
//        CGPoint prev = [engine.level convertPoint:[touch previousLocationInView:touch.view] fromLayer:self.scroll];
//        CGPoint loc = [engine.level convertPoint:[touch locationInView:touch.view] fromLayer:self.scroll];
//        
//        CGRect bounds = self.scroll.bounds;
//        
//        bounds.origin.x += prev.x - loc.x;
//        bounds.origin.y += prev.y - loc.y;
//        
//        [self scrollTo:bounds];
//        
//    } else if (tracked.count) {
//        NSMutableDictionary* first = [self path:event];
//        __block CGPoint center = CGPointZero;
//        __block CGFloat origdist = 0.0f;
//        [tracked enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
//            CGPoint loc = [touch locationInView:touch.view];
//            KWTouch* ktouch = [first objectForKey:[touch ptr]];
//            origdist += ktouch.distance;
//            
//            center.x += loc.x;
//            center.y += loc.y;
//        }];
//        center.x /= tracked.count;
//        center.y /= tracked.count;
//        origdist /= tracked.count;
//        
//        __block CGFloat distance = 0.0f;
//        [tracked enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
//            CGPoint loc = [touch locationInView:touch.view];
//            distance += CGLineDistance((CGLine){center, loc});
//        }];
//        distance /= tracked.count;
//        
//        [self zoom:(distance / origdist) * zoom];
//    }
//}
//
//- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
//    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *tstop) {
//        [self untrack:touch forEvent:event];
//        [engine.level.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *kstop) {
//            if (o.touch == touch) {
//                o.touch = nil;
//                [KWGFX animate:^{ o.position = [engine.level convertPoint:[touch locationInView:touch.view] fromLayer:self.scroll]; }];
//                [engine.level capture:o];
//            }
//        }];
//    }];
//    
//    if (scroller.timestamp) {
//        NSTimeInterval dt =  event.timestamp - scroller.timestamp;
//        CGLine scrolled = CGLineMake(scroller.location, self.scroll.bounds.origin);
//        scroller.velocity.x = CGLineSlopeX(scrolled) / dt;
//        scroller.velocity.y = CGLineSlopeY(scrolled) / dt;
//    }
//    
//}
//
//- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
//    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
//        [self untrack:touch forEvent:event];
//        [engine.level.objects enumerateObjectsUsingBlock:^(KWObject* o, NSUInteger idx, BOOL *stop) {
//            if (o.touch == touch) { o.touch = nil; }
//        }];
//    }];
//}

@end
