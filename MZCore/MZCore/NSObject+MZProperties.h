//
//  NSObject+MZProperties.h
//  MZCore
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (MZProperties)

- (NSArray*) properties;
- (NSString*) propertyType:(NSString*)propertyName;
- (Class) classForProperty:(NSString*)propertyName;

@end
