//
//  NSObject+MZProperties.m
//  MZCore
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "NSObject+MZProperties.h"
#import "NSString+MZRegexp.h"

@implementation NSObject (MZProperties)

- (NSArray*) properties {
    
    NSMutableArray* properties = [[NSMutableArray alloc] init];
    
    Class class = [self class];    
    
	while (class != nil && ![class isEqual:[NSObject class]]) {
        
        NSUInteger		  property_count;
        objc_property_t * property_list = class_copyPropertyList(class, &property_count);
        
        for (int i = 0; i < property_count; i++) { 
            objc_property_t property = property_list[i];
            const char * property_name = property_getName(property);        
            NSString * propertyName = [NSString stringWithCString:property_name encoding:NSASCIIStringEncoding];            
            if (propertyName) { [properties addObject:propertyName]; }
        }
        free(property_list);
        
        class = class_getSuperclass(class); 
	}
    
    return properties;
}

- (Class) classForProperty:(NSString*)propertyName {
    objc_property_t property = class_getProperty([self class], [propertyName cStringUsingEncoding:NSASCIIStringEncoding]); 
    
    NSString* attrs = [NSString stringWithCString:property_getAttributes(property) encoding:NSASCIIStringEncoding];    
    return NSClassFromString([attrs capture:@"^T@\"(.*)\",.*$"]);
}

- (NSString*) decodePropertyType:(const char*)attrs {
    
    switch (attrs[1]) {
        case 'c':
            return @"char";
        case 'i':
            return @"int";
        case 's':
            return @"short";
        case 'l':
            return @"long";
        case 'q':
            return @"long long";
        case 'C':
            return @"unsigned char";
        case 'I':
            return @"unsigned int";
        case 'S':
            return @"unsigned short";
        case 'L':
            return @"unsigned long";
        case 'Q':
            return @"unsigned long long";
        case 'f':
            return @"float";
        case 'd':
            return @"double";
        case 'B':
            return @"bool";
        case 'v':
            return @"void";
        case '*':
            return @"char *";
        case '#':
            return @"Class";
        case ':':
            return @"SEL";
            break;
        case '[':
            return @"carray";
        case '{':
            return @"struct";
        case '(':
            return @"union";
        case 'b':
            return @"bitfield";
        case '^':
            return [NSString stringWithFormat:@"%@*", [self decodePropertyType:++attrs]];
        case '?':
            return @"unknown";
    }
    
    NSString* type = [[NSString stringWithCString:attrs encoding:NSASCIIStringEncoding] capture:@"^T@\"([^\"]*)\",.*$"];
    
    if (type == nil) {
        return @"id";
    } else if ([type characterAtIndex:0] == '<') {
        return [NSString stringWithFormat:@"id%@", type];
    } else {
        return [NSString stringWithFormat:@"%@*", type];                
    }
    
}

- (NSString*) propertyType:(NSString*)propertyName {
    objc_property_t property = class_getProperty([self class], [propertyName cStringUsingEncoding:NSASCIIStringEncoding]);
    const char * attrs = property_getAttributes(property);
    return [self decodePropertyType:attrs];
}


@end
