//
//  UIView+LLUtil.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "UIView+LL.h"
#import <objc/runtime.h>

#import "NSObject+LL.h"
#import "NSString+LL.h"

@implementation UIView (LL)

- (CGPoint) origin { return self.frame.origin; }
- (void) setOrigin:(CGPoint)origin { self.frame = (CGRect) { origin, self.frame.size }; }

- (CGSize) size { return self.frame.size; }
- (void) setSize:(CGSize)size { self.frame = (CGRect) { self.frame.origin, size }; }

- (CGFloat) width { return self.frame.size.width; }
- (void) setWidth:(float)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat) height { return self.frame.size.height; }
- (void) setHeight:(float)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;}

- (CGFloat) x { return self.frame.origin.x; }
- (void) setX:(float)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;}

- (CGFloat) y { return self.frame.origin.y; }
- (void) setY:(float)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void) setBorderWidth:(CGFloat)width {
    self.layer.borderWidth = width;
}

- (void) setBorderColor:(UIColor*)color {
    self.layer.borderColor = [color CGColor];
}

- (void) setBorderRounding:(CGFloat)radius {
    self.layer.cornerRadius = radius;
}

- (void) clearActions {
//xxx
}

- (void) setAction:(NSDictionary*)action {
    [self clearActions];
    [self addAction:action];
}

- (void) addActions:(NSArray*)actions {
    [self clearActions];
    [actions enumerateObjectsUsingBlock:^(NSDictionary* action, NSUInteger idx, BOOL *stop) {
        [self addAction:action];
    }];
}

- (UIControlEvents) controlEventFor:(NSString*)name {
    if ([name hasSuffix:@"down"]) {
        return UIControlEventTouchDown;
    } else if ([name hasSuffix:@"repeat"]) {
        return UIControlEventTouchDownRepeat;
    } else if ([name hasSuffix:@"draginside"]) {
        return UIControlEventTouchDragInside;
    } else if ([name hasSuffix:@"dragoutside"]) {
        return UIControlEventTouchDragOutside;
    } else if ([name hasSuffix:@"enter"]) {
        return UIControlEventTouchDragEnter;
    } else if ([name hasSuffix:@"exit"]) {
        return UIControlEventTouchDragExit;
    } else if ([name hasSuffix:@"inside"] || [name isEqualToString:@"up"]) {
        return UIControlEventTouchUpInside;
    } else if ([name hasSuffix:@"outside"]) {
        return UIControlEventTouchUpOutside;
    } else if ([name hasSuffix:@"didbegin"]) {
        return UIControlEventEditingDidBegin;
    } else if ([name hasSuffix:@"didend"]) {
        return UIControlEventEditingDidEnd;
    } else if ([name hasSuffix:@"onexit"]) {
        return UIControlEventEditingDidEndOnExit;
    } else if ([name hasSuffix:@"editingchanged"]) {
        return UIControlEventEditingChanged;
    } else if ([name hasSuffix:@"changed"]) {
        return UIControlEventValueChanged;
    } else if ([name hasPrefix:@"alltouch"] || [name isEqualToString:@"touch"]) {
        return UIControlEventAllTouchEvents;
    } else if ([name hasPrefix:@"allediting"] || [name isEqualToString:@"editing"]) {
        return UIControlEventAllEditingEvents;
    } else if ([name hasPrefix:@"all"] || [name isEqualToString:@"any"]) {
        return UIControlEventAllEvents;
    } else {
        return UIControlEventTouchUpInside;
    }
}

- (void) addAction:(NSDictionary*)action {
    //split action apart
    NSString* event = [[action valueForPath:@"event"] lowercaseString]; //click, swipe, etc
    NSString* type = [[action valueForPath:@"type"] lowercaseString];
    
    //xxx check that event isn't gesture?
    [self addGestureRecognizer:]

    
    if ([type isEqualToString:@"push"]) {
        //transition
        //view
    } else if ([type isEqualToString:@"back/pop"]) {
        //transition
        if ([self isKindOfClass:UIControl.class]) {
            //xxx nil proagates up?
            //xxx how to add action properly?
            [((UIControl*)self) addTarget:nil action:@selector(back) forControlEvents:[self controlEventFor:event]];
        }
    } else if ([type isEqualToString:@"open"]) {
        //url
    } else if ([type isEqualToString:@"call"]) {
        //tel
    } else if ([type isEqualToString:@"send"]) {
        //data 2 api
    } else if ([type isEqualToString:@"perform"]) {
        //selector
        //data
        //obj?
    } else if ([type isEqualToString:@"animate?"]) {
    }
    
    //xxx 
    //check if is gesture
    //check if sel if UIControl
    //  if not, add UIControl/gesture to self
    
    //actions can be precanned
    //or selectors
    
}


@end
