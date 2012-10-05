//
//  LLAlert.m
//  Catpcha
//
//  Created by Mason on 8/1/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "LLAlert.h"

@implementation LLAlert {
    NSDictionary* actions;
    UIAlertView* alert;
}

+ (NSMutableArray*) alerts {
    static NSMutableArray* alerts;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ alerts = [[NSMutableArray alloc] init]; });
    return alerts;
}

+ (void) alert:(NSString*)title message:(NSString*)message actions:(NSDictionary*)actions   {
    LLAlert* alert = [[LLAlert alloc] initWithTitle:title message:message actions:actions];
    [[self alerts] addObject:alert];
    [alert show];
}

- (id) initWithTitle:(NSString*)title message:(NSString*)message actions:(NSDictionary*)buttons {
    if (self = [self init]) {
        actions = buttons;
        alert = [[UIAlertView alloc] initWithTitle:title
                                           message:message
                                          delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
        [actions enumerateKeysAndObjectsUsingBlock:^(NSString* button, id block, BOOL *stop) {
            [alert addButtonWithTitle:button];
            if (![block isEqual:[NSNull null]]) { [block copy]; }
        }];
    }
    return self;
}

- (void) show { [alert show]; }

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    void(^action)(void) = [actions objectForKey:[alertView buttonTitleAtIndex:buttonIndex]];
    if (action) { action(); }
    [[[self class] alerts] removeObject:self];
}


@end
