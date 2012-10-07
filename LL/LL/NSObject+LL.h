//
//  NSObject+LL.h
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

@interface NSObject (LL)

- (id) valueForPath:(NSString*)path;
- (void) setValue:(id)value forPath:(NSString*)path;

- (void) walk:(void(^)(NSString* key, id value))block;
- (void) walk:(void(^)(NSString* key, id value))block withPrefix:(NSString*)prefix;

- (void) listenFor:(NSString*)notification andInvoke:(void(^)(NSNotification *note))nvok;
- (void) listenFor:(NSString*)notification andPerform:(SEL)selector;

- (void) stopListeningFor:(NSString*)notification;
- (void) stopListeningForNotifications;

- (void) postNotice:(NSString*)notification;
- (void) postNotice:(NSString*)notification withObject:(id)object;

@end
