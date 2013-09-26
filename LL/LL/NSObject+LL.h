//
//  NSObject+LL.h
//  LL
//
//  Created by Mason on 10/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

@interface NSObject (LL)

typedef enum {
    
    LLPropertyTypeChar             = 'c',
    LLPropertyTypeInt              = 'i',
    LLPropertyTypeShort            = 's',
    LLPropertyTypeLong             = 'l',
    LLPropertyTypeLongLong         = 'q',
    LLPropertyTypeUnsignedChar     = 'C',
    LLPropertyTypeUnsignedInt      = 'I',
    LLPropertyTypeUnsignedShort    = 'S',
    LLPropertyTypeUnsignedLong     = 'L',
    LLPropertyTypeUnsignedLongLong = 'Q',
    LLPropertyTypeFloat            = 'f',
    LLPropertyTypeDouble           = 'd',
    LLPropertyTypeBool             = 'B',
    LLPropertyTypeVoid             = 'v',
    LLPropertyTypeCString          = '*',
    LLPropertyTypeClass            = '#',
    LLPropertyTypeSelector         = ':',
    LLPropertyTypeCArray           = '[',
    LLPropertyTypeStruct           = '{',
    LLPropertyTypeUnion            = '(',
    LLPropertyTypeBitfield         = 'b',
    LLPropertyTypePointer          = '^',
    LLPropertyTypeObject           = '@',
    LLPropertyTypeUnknown          = '?'
    
} LLPropertyType;

- (void) setLLID:(NSString*)llid;
- (NSString*) LLID;

- (NSString*) str;

+ (NSArray*) properties;

+ (BOOL) isDynamicProperty:(NSString*)selector;

+ (NSString*) lookupPropertyName:(SEL)selector;
+ (Class) classForProperty:(NSString*)propertyName;
+ (char) encodedPropertyType:(NSString*)propertyName;

+ (BOOL) isSetter:(SEL)selector;
+ (BOOL) isGetter:(SEL)selector;

+ (BOOL) isObjectProperty:(NSString*)property;
+ (BOOL) isPrimitiveProperty:(NSString*)property;
+ (BOOL) hasProperty:(NSString*)property;
+ (BOOL) hasPropertyForSelector:(SEL)selector;

+ (NSString*) propertyTypeString:(NSString*)propertyName;

+ (void) createPropertyMethodsForSelector:(SEL)selector;
+ (void) createMethodsForProperty:(NSString*)property;

- (NSArray*) properties;
- (NSString*) lookupPropertyName:(SEL)selector;
- (Class) classForProperty:(NSString*)propertyName;
- (char) encodedPropertyType:(NSString*)propertyName;

- (BOOL) isSetter:(SEL)selector;
- (BOOL) isGetter:(SEL)selector;

- (BOOL) isObjectProperty:(NSString*)property;
- (BOOL) isPrimitiveProperty:(NSString*)property;

- (NSString*) propertyTypeString:(NSString*)propertyName;

- (void) encodeProperties:(NSCoder*)coder;
- (void) decodeProperties:(NSCoder*)decoder;

- (void) setValue:(id)value forDynamicProperty:(NSString *)property;
- (id) getValueForDynamicProperty:(NSString *)property;
- (NSMutableDictionary*) dynamicProperties;

- (id) valueForPath:(id)path;
- (void) setValue:(id)value forPath:(NSString*)path;

- (void) walk:(void(^)(NSString* key, id value))block;
- (void) walk:(void(^)(NSString* key, id value))block referencing:(id)data;

- (void) listenFor:(NSString*)notification andInvoke:(void(^)(NSNotification *note))nvok;
- (void) listenFor:(NSString*)notification andPerform:(SEL)selector;

- (void) stopListeningFor:(NSString*)notification;
- (void) stopListeningForNotifications;

- (void) postNotice:(NSString*)notification;
- (void) postNotice:(NSString*)notification withObject:(id)object;

@end
