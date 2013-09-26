//
//  NSObject+LL.m
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "NSObject+LL.h"
#import "NSString+LL.h"
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

#define kLLPropertyPattern @"^(?:(?:setPrimitive|set)([A-Z][^:]*):|(?:primitive|getPrimitive|get)([A-Z][^:]*)|([a-z]+[^:]*))$"

@implementation NSObject (LL)

- (NSString*) LLID {
    
    NSString* llid = [self getValueForDynamicProperty:@"llid"];
    
    if (llid == nil) {
        
        NSString* selfClass = NSStringFromClass(self.class);
        selfClass = [selfClass stringByReplacingOccurrencesOfString:@"__" withString:@""];
        selfClass = [selfClass stringByReplacingOccurrencesOfString:@"NSCF" withString:@"NS"];
        selfClass = [selfClass stringByReplacingOccurrencesOfString:@"CF" withString:@""];
        selfClass = [selfClass stringByReplacingOccurrencesOfString:@"Concrete" withString:@""];
        
        NSString* uniq = [[NSProcessInfo processInfo] globallyUniqueString];
                
        llid = ns(@"%@.%@", uniq, selfClass);
        
        [self setLLID:llid];
    }
    
    return llid;
}

- (void) setLLID:(NSString*)llid {
    
    [self setValue:llid forDynamicProperty:@"llid"];
    
}


+ (NSArray*) properties {
    
    NSMutableArray* properties = [[NSMutableArray alloc] init];
    
    Class class = self;
    
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

+ (BOOL) isSetter:(SEL)selector { return [NSStringFromSelector(selector) matches:@"^set[A-Z][^:]*:$"]; }

+ (BOOL) isGetter:(SEL)selector { return ![self isSetter:selector] && [NSStringFromSelector(selector) matches:@"^[a-z][^:]*$"]; }

+ (NSString*) extractPropertyName:(NSString*)from {
    NSString* found = [from match:kLLPropertyPattern];
    
    if (found) {
        found = [[NSString alloc] initWithFormat:@"%@%@",[[found substringToIndex:1] lowercaseString], [found substringFromIndex:1]];
    }
    
    return found;
}

+ (NSString*) lookupPropertyName:(SEL)selector {
    return [self extractPropertyName:NSStringFromSelector(selector)];
}

+ (Class) classForProperty:(NSString*)propertyName {
    objc_property_t property = class_getProperty([self class], [propertyName cStringUsingEncoding:NSASCIIStringEncoding]);
    
    NSString* attrs = [NSString stringWithCString:property_getAttributes(property) encoding:NSASCIIStringEncoding];
    return NSClassFromString([attrs match:@"^T@\"(.*)\",.*$"]);
}

+ (const char*) propertyAtrributes:(NSString*)propertyName {
    objc_property_t property = class_getProperty(self, [propertyName cStringUsingEncoding:NSASCIIStringEncoding]);
    return property == nil ? nil : property_getAttributes(property);
}

+ (char) encodedPropertyType:(NSString*)propertyName {
    const char* attrs = [self propertyAtrributes:propertyName];
    return attrs == nil ? LLPropertyTypeUnknown : attrs[1];
}
+ (BOOL) isObjectProperty:(NSString*)property { return [self encodedPropertyType:property] == LLPropertyTypeObject; }
+ (BOOL) isPrimitiveProperty:(NSString*)property { return ![self isObjectProperty:property]; }

- (NSArray*) properties { return [[self class] properties]; }
- (NSString*) lookupPropertyName:(SEL)selector { return [[self class] lookupPropertyName:selector]; }
- (Class) classForProperty:(NSString*)propertyName { return [[self class] classForProperty:propertyName]; }
- (char) encodedPropertyType:(NSString*)propertyName { return [[self class] encodedPropertyType:propertyName]; }

- (BOOL) isSetter:(SEL)selector { return [[self class] isGetter:selector]; }
- (BOOL) isGetter:(SEL)selector { return [[self class] isSetter:selector]; }

- (BOOL) isObjectProperty:(NSString*)property { return [[self class] isObjectProperty:property]; }
- (BOOL) isPrimitiveProperty:(NSString*)property { return [[self class] isPrimitiveProperty:property]; }

- (NSString*) propertyTypeString:(NSString*)propertyName { return [[self class] propertyTypeString:propertyName]; }

- (void) encodeProperties:(NSCoder*)coder {
    
    id value;
    NSArray *properties = [self properties];
    for (NSString* property in properties) {
        value = [self valueForKey:property];
        
        if (value != nil) {
            [coder encodeObject:value forKey:property];
        }
    }
    
}

- (void) decodeProperties:(NSCoder*)decoder {
    
    id value;
    NSArray *properties = [self properties];
    for (NSString* property in properties) {
        value = [decoder decodeObjectForKey:property];
        if (value != nil) {
            [self setValue:value forKey:property];
        }
    }
    
}

+ (NSString*) decodePropertyType:(const char*)attrs {
    
    switch (attrs[1]) {
        case LLPropertyTypeChar:             return @"char";
        case LLPropertyTypeInt:              return @"int";
        case LLPropertyTypeShort:            return @"short";
        case LLPropertyTypeLong:             return @"long";
        case LLPropertyTypeLongLong:         return @"long long";
        case LLPropertyTypeUnsignedChar:     return @"unsigned char";
        case LLPropertyTypeUnsignedInt:      return @"unsigned int";
        case LLPropertyTypeUnsignedShort:    return @"unsigned short";
        case LLPropertyTypeUnsignedLong:     return @"unsigned long";
        case LLPropertyTypeUnsignedLongLong: return @"unsigned long long";
        case LLPropertyTypeFloat:            return @"float";
        case LLPropertyTypeDouble:           return @"double";
        case LLPropertyTypeBool:             return @"bool";
        case LLPropertyTypeVoid:             return @"void";
        case LLPropertyTypeCString:          return @"char *";
        case LLPropertyTypeClass:            return @"Class";
        case LLPropertyTypeSelector:         return @"SEL";
        case LLPropertyTypeCArray:           return @"carray";
        case LLPropertyTypeStruct:           return @"struct";
        case LLPropertyTypeUnion:            return @"union";
        case LLPropertyTypeBitfield:         return @"bitfield";
        case LLPropertyTypePointer:          return [NSString stringWithFormat:@"%@*", [self decodePropertyType:++attrs]];
        case LLPropertyTypeUnknown:          return @"unknown";
    }
    
    NSString* type = [[NSString stringWithCString:attrs encoding:NSASCIIStringEncoding] match:@"^T@\"([^\"]*)\",.*$"];
    
    if (type == nil) {
        return @"id";
    } else if ([type characterAtIndex:0] == '<') {
        return [NSString stringWithFormat:@"id%@", type];
    } else {
        return [NSString stringWithFormat:@"%@*", type];
    }
    
}

+ (NSString*) propertyTypeString:(NSString*)propertyName { return [self decodePropertyType:[self propertyAtrributes:propertyName]]; }

- (NSMutableDictionary*) dynamicProperties {
    
    NSMutableDictionary* dynamic = objc_getAssociatedObject(self, (__bridge void*)self);
    
    if (dynamic == nil) {
        
        @synchronized(self) {
            
            dynamic = objc_getAssociatedObject(self, (__bridge void*)self);
            
            if (dynamic == nil) {
                
                dynamic = [[NSMutableDictionary alloc] init];
                
                objc_setAssociatedObject(self, (__bridge void*)self, dynamic, OBJC_ASSOCIATION_RETAIN);
                
            }
        }
    }
    
    return dynamic;
}

- (void) setValue:(id)value forDynamicProperty:(NSString *)property {
    if (value == nil) {
        [[self dynamicProperties] removeObjectForKey:property];
    } else {
        [[self dynamicProperties] setObject:value forKey:property];
    }
}

- (id) getValueForDynamicProperty:(NSString *)property {
    
    return [[self dynamicProperties] objectForKey:property];
}

+ (BOOL) isDynamicProperty:(NSString*)selector {
    
    NSString* property = [self extractPropertyName:selector];
    
    objc_property_t prop = class_getProperty(self, [property cStringUsingEncoding:NSASCIIStringEncoding]);
    if (prop) {
        NSString* attrs = [[NSString alloc] initWithCString:property_getAttributes(prop) encoding:NSASCIIStringEncoding];
        NSArray* attributes = [attrs split:@","];
        return [[attributes lastObject] isEqual:@"D"];
    }
    
    return NO;
    
}

+ (void) synthesizeMethod:(NSString*)selector imp:(IMP)implementation types:(const char *)types {
    
    if ([self isDynamicProperty:selector]) {
        //xxx actually, check if method exists
        //        DLog(@"Synthesizing %@", selector);
        class_addMethod(self, NSSelectorFromString(selector), implementation, types);
    }
    
}

static IMP implementationWithBlock(id block) {
    
#if __IPHONE_6_0
    return imp_implementationWithBlock([block copy]);
#else
    return imp_implementationWithBlock((__bridge void *)[block copy]);
#endif
    
}

+ (void) addObjectPropertyMethods:(NSString*)property {
    
    NSString* getSelector = [[NSString alloc] initWithFormat:@"get%@%@", [[property substringToIndex:1] uppercaseString], [property substringFromIndex:1]];
    
    NSString* setSelector = [NSString stringWithFormat:@"set%@%@:",[[property substringToIndex:1] uppercaseString],[property substringFromIndex:1]];
    
    [self synthesizeMethod:setSelector imp:implementationWithBlock(^(id _self, id value) { [_self setValue:value forDynamicProperty:property]; }) types:"v@:@"];
    
    id (^getter)(id) = ^(id _self) { return [_self getValueForDynamicProperty:property]; };
    
    [self synthesizeMethod:property
                       imp:implementationWithBlock(getter)
                     types:"@@:"];
    [self synthesizeMethod:getSelector
                       imp:implementationWithBlock(getter)
                     types:"@@:"];
    
    
}

+ (void) addPrimitivePropertyMethods:(NSString*)property {
    
    NSString* caseProp = [[NSString alloc] initWithFormat:@"%@%@", [[property substringToIndex:1] uppercaseString], [property substringFromIndex:1]];
    
    NSArray* getSelectors = [[NSArray alloc] initWithObjects:
                             property,
                             [NSString stringWithFormat:@"get%@",caseProp],
                             [NSString stringWithFormat:@"getPrimitive%@",caseProp],
                             nil];
    
    NSArray* setSelectors = [[NSArray alloc] initWithObjects:
                             [NSString stringWithFormat:@"set%@:",caseProp],
                             [NSString stringWithFormat:@"setPrimitive%@:",caseProp],
                             nil];
    
    char type = [self encodedPropertyType:property];
    
    const char* setType = [[[NSString alloc] initWithFormat:@"v@:%c", type] cStringUsingEncoding:NSASCIIStringEncoding];
    const char* getType = [[[NSString alloc] initWithFormat:@"%c@:", type] cStringUsingEncoding:NSASCIIStringEncoding];
    
    switch (type) {
        case LLPropertyTypeChar:
            for (NSString* selector in setSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self, char value) {
                    [_self setValue:[NSNumber numberWithChar:value] forDynamicProperty:property]; }) types:setType];
            }
            
            for (NSString* selector in getSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self) {
                    return [[_self getValueForDynamicProperty:property] charValue]; }) types:getType];
            }
            
            break;
            
        case LLPropertyTypeInt:
            for (NSString* selector in setSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self, int value) {
                    [_self setValue:[NSNumber numberWithInt:value] forDynamicProperty:property]; }) types:setType];
            }
            
            for (NSString* selector in getSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self) {
                    return [[_self getValueForDynamicProperty:property] intValue]; }) types:getType];
            }
            
            break;
            
        case LLPropertyTypeLong:
            for (NSString* selector in setSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self, long value) {
                    [_self setValue:[NSNumber numberWithLong:value] forDynamicProperty:property]; }) types:setType];
            }
            
            for (NSString* selector in getSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self) {
                    return [[_self getValueForDynamicProperty:property] longValue]; }) types:getType];
            }
            
            break;
            
        case LLPropertyTypeBool:
            for (NSString* selector in setSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self, BOOL value) {
                    [_self setValue:[NSNumber numberWithBool:value] forDynamicProperty:property]; }) types:setType];
            }
            
            for (NSString* selector in getSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self) {
                    return [[_self getValueForDynamicProperty:property] boolValue]; }) types:getType];
            }
            
            break;
            
        case LLPropertyTypeFloat:
            for (NSString* selector in setSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self, float value) {
                    [_self setValue:[NSNumber numberWithFloat:value] forDynamicProperty:property]; }) types:setType];
            }
            
            for (NSString* selector in getSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self) {
                    return [[_self getValueForDynamicProperty:property] floatValue]; }) types:getType];
            }
            
            break;
            
        case LLPropertyTypeDouble:
            for (NSString* selector in setSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self, double value) {
                    [_self setValue:[NSNumber numberWithDouble:value] forDynamicProperty:property]; }) types:setType];
            }
            
            for (NSString* selector in getSelectors) {
                [self synthesizeMethod:selector imp:implementationWithBlock(^(id _self) {
                    return [[_self getValueForDynamicProperty:property] doubleValue]; }) types:getType];
            }
            
            break;
            
        default:
            dlog(@"WARNING: Can't create methods for type %c", type);
            break;
    }
    
}

+ (BOOL) hasProperty:(NSString*)property {
    objc_property_t prop = class_getProperty(self, [property cStringUsingEncoding:NSASCIIStringEncoding]);
    
    return prop != nil;
}

+ (BOOL) hasPropertyForSelector:(SEL)selector {
    return [self hasProperty:[self lookupPropertyName:selector]];
}

+ (void) createPropertyMethodsForSelector:(SEL)selector {
    //xxx actually, just do one method at a time
    
    
    [self createMethodsForProperty:[self lookupPropertyName:selector]];
}

+ (void) createMethodsForProperty:(NSString*)property {
    
    if ([self isPrimitiveProperty:property]) {
        [self addPrimitivePropertyMethods:property];
    } else {
        [self addObjectPropertyMethods:property];
    }
    
}

- (NSString*) str {
    if ([self isKindOfClass:NSString.class]){
        return (NSString*)self;
    } else if ([self respondsToSelector:@selector(stringValue)]) {
        return [self performSelector:@selector(stringValue)];
    } else {
        return [self description];
    }
}

- (void) listenFor:(NSString*)notification andInvoke:(void(^)(NSNotification *note))nvok { [[NSNotificationCenter defaultCenter] addObserverForName:notification object:nil queue:nil usingBlock:nvok]; }
- (void) listenFor:(NSString*)notification andPerform:(SEL)selector { [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:notification object:nil]; }
- (void) stopListeningFor:(NSString*)notification { [[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:nil]; }
- (void) stopListeningForNotifications { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void) postNotice:(NSString*)notification { [self postNotice:notification withObject:nil]; }
- (void) postNotice:(NSString*)notification withObject:(id)object { [[NSNotificationCenter defaultCenter] postNotificationName:notification object:object]; }

- (id) expand:(id)value {
    static NSRegularExpression* expander;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        expander = [NSRegularExpression regularExpressionWithPattern:@"^\\#\\{(.*)\\}$" options:0 error:NULL];
    });
    
    NSString* path = nil;
    if ((path = [[value str] match:expander]) != nil) {
        value = [self valueForPath:path root:self];
    }
    //xxx  need to copy value, probably
    return value;
}

- (id) valueForPath:(id)path {
    if ([path isKindOfClass:NSArray.class]) {
        __block id val = nil;
        [path enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            val = [self valueForPath:[obj str]];
            if (val) {
                *stop = YES;
            }
        }];
        return val;
    }
    return [self valueForPath:[path str] root:self];
}

- (id) valueForPath:(NSString*)path root:(id)root {
    NSArray* split = [path split:@".["];
    __block id value = self;
    [split enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
        key = [key trim:@"[]"];
        if ([value isKindOfClass:NSArray.class]) {
            NSInteger index = [key intValue];
            value = [value objectAtIndex:index];
        } else if ([value isKindOfClass:NSDictionary.class]) {
            value = [value valueForKey:key];
        } else {
            value = [root expand:value];
        }
    }];
    
    return [root expand:value];
}

- (void) setValue:(id)value forPath:(NSString*)path {
    [self setValue:value forPath:path root:self];
}

- (void) setValue:(id)value forPath:(NSString*)path root:(id)root {
    NSArray* split = [path split:@".["];
    
    NSString* key = nil;
    id current = self;
    for (int i = 0; i < split.count - 1; i++) {
        key = [[split objectAtIndex:i] trim:@"[]"];
        
        if ([current isKindOfClass:NSMutableArray.class]) {
            NSInteger index = [key intValue];
            if (index >= [current count]) {
                int missing = (1 + index - [current count]);
                for (int fill = 0; fill < missing; fill++){
                    [current addObject:[NSNull null]];
                }
            }
            
            id next = [current objectAtIndex:index];
            if ([next isEqual:[NSNull null]]) {
                NSString* nextKey = [split objectAtIndex:i + 1];
                if ([nextKey hasSuffix:@"]"]) {
                    next = [NSMutableArray array];
                    [current setObject:next atIndex:index];
                } else {
                    next = [NSMutableDictionary dictionary];
                    [current setObject:next atIndex:index];
                }                
            }
            current = next;
        } else if ([current isKindOfClass:NSMutableDictionary.class]) {
            id next = [current valueForKey:key];
            if (next == nil) {
                NSString* nextKey = [split objectAtIndex:i + 1];
                if ([nextKey hasSuffix:@"]"]) {
                    next = [NSMutableArray array];
                    [current setObject:next forKey:key];
                } else {
                    next = [NSMutableDictionary dictionary];
                    [current setObject:next forKey:key];
                }                
            }
            current = next;
        }
    }
    
    key = [split.lastObject trim:@"[]"];
    if ([current isKindOfClass:NSMutableArray.class]) {
        NSInteger index = [key intValue];
        [current setObject:[root expand:value] atIndex:index];
    } else if ([current isKindOfClass:NSMutableDictionary.class]) {
        [current setValue:[root expand:value] forKey:key];
    }
    
}

- (void) walk:(void(^)(NSString* key, id value))block {
    [self walk:block withPrefix:nil root:self];
}

- (void) walk:(void(^)(NSString* key, id value))block referencing:(id)data {
    [self walk:block withPrefix:nil root:data];
}

- (void) walk:(void(^)(NSString* key, id value))block withPrefix:(NSString*)prefix root:(id)root {
    
    if ([self isKindOfClass:NSDictionary.class]) {
        [((NSDictionary*)self) enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
            key = prefix ? [prefix stringByAppendingFormat:@".%@", key] : key;
            if ([value isKindOfClass:NSDictionary.class] || [value isKindOfClass:NSArray.class]) {
                [value walk:block withPrefix:key root:root];
            } else {
                block(key, [root expand:value]);
            }
        }];
    } else if ([self isKindOfClass:NSArray.class]) {
        [((NSArray*)self) enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
            NSString* key = prefix ? [prefix stringByAppendingFormat:@"[%d]", idx] : ns(@"[%d]", idx);
            if ([value isKindOfClass:NSDictionary.class] || [value isKindOfClass:NSArray.class]) {
                [value walk:block withPrefix:key root:root];
            } else {
                block(key, [root expand:value]);
            }            
        }];
    } else {
        block(@"", self);
    }
    
}


@end
