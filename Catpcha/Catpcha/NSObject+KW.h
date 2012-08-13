//
//  NSObject+KWO.h
//  Catpcha
//
//  Created by Mason on 8/3/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

@interface NSObject (KW)

- (void) observe:(NSString*)keyPath with:(void(^)(NSDictionary* change))block;
- (NSValue*) ptr;

@end
