//
//  MaSONKit.m
//  MaSONKit
//
//  Created by Mason Glaves on 4/24/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MaSONKit.h"

#define kMaPageCapacity 1024
#define kMaMaxPages 256

#define kMaInitialCapacity 32

#define OFTEN_TRUE(cond)  __builtin_expect(cond, true)
#define OFTEN_FALSE(cond) __builtin_expect(cond, false)

static NSUInteger arrayCapacityWindow = kMaInitialCapacity;
static NSUInteger hashCapacityWindow = kMaInitialCapacity;

typedef enum { MaNull, MaTrue, MaFalse, MaString, MaNumber, MaArray, MaHash } MaType;

typedef struct _MaObject { 
    MaType type; 
    const char* start; 
    NSUInteger length; 
    NSUInteger capacity; 
    struct _MaObject** keys; 
    struct _MaObject** values;     
} MaObject;

typedef struct {
    NSInteger index;    
    NSInteger count;    
    MaObject** pages;    
} MaBuffer;

static inline MaBuffer* MaBufferMake() { 
    MaBuffer* buffer = malloc(sizeof(MaBuffer));
    buffer->index = 0;
    buffer->count = 0;
    buffer->pages = malloc(kMaMaxPages * sizeof(MaObject*));    
    return buffer;
}

static inline MaObject* MaMalloc(register MaBuffer* const buffer, register const MaType const type) { 
    if (OFTEN_FALSE(buffer->index >= buffer->count * kMaPageCapacity)) {
        if (OFTEN_FALSE(buffer->count == kMaMaxPages)) {
            [NSException raise:@"MaSizeTooDamnHighException" format:@"That's one big god damn file!"];
            abort();
        }
        buffer->pages[buffer->count++] = malloc(kMaPageCapacity * sizeof(MaObject));
    }
    
    register NSInteger page = buffer->index / kMaPageCapacity;
    register NSInteger index = buffer->index % kMaPageCapacity;
    
    MaObject* o = &buffer->pages[page][index];
    buffer->index++;
    
    o->type = type; 
    switch (type) {
        case MaHash:  
            o->capacity = hashCapacityWindow; 
            o->keys = malloc(o->capacity * sizeof(MaObject*));
        case MaArray:            
            o->capacity = arrayCapacityWindow; 
            o->values = malloc(o->capacity * sizeof(MaObject*));
        default:
            o->start = 0;
            o->length = 0;
    }
    return o;    
}

static const MaObject MaNullObject  = { MaNull  };
static const MaObject MaTrueObject  = { MaTrue  };
static const MaObject MaFalseObject = { MaFalse };

static inline MaObject* MaObjectMake(register MaBuffer *buffer, const MaType const type) { 
    MaObject* o = MaMalloc(buffer, type);
    o->type = type; 
    switch (type) {
        case MaHash:  
            o->capacity = hashCapacityWindow; 
            o->keys = malloc(o->capacity * sizeof(MaObject*));
        case MaArray:            
            o->capacity = arrayCapacityWindow; 
            o->values = malloc(o->capacity * sizeof(MaObject*));
        default:
            o->start = 0;
            o->length = 0;
    }
    return o;
}

static inline MaObject* MaStringMake(register MaBuffer *buffer, const char* const start, const NSUInteger length) { 
    MaObject* s = MaObjectMake(buffer, MaString);
    s->start = start;
    s->length = length; 
    return s;
}

static inline MaObject* MaNumberMake(register MaBuffer *buffer, const char* const start, const NSUInteger length) { 
    MaObject* n = MaObjectMake(buffer, MaNumber);
    n->start = start; 
    n->length = length; 
    return n;
}

static inline MaObject* MaArrayMake(MaBuffer *buffer) { return MaObjectMake(buffer, MaArray); }

static inline MaObject* MaHashMake(MaBuffer *buffer) { return MaObjectMake(buffer, MaHash); }

static inline void MaSet(MaObject* const o, MaObject* key, MaObject* value) {
    
    switch (o->type) {
        case MaHash:
            if (OFTEN_FALSE(o->length == o->capacity)) {
                o->capacity += o->capacity;
                hashCapacityWindow = MAX(o->capacity, hashCapacityWindow);  
                o->keys = realloc(o->keys, o->capacity);
                o->values = realloc(o->values, o->capacity);
            }
            
            o->keys[o->length] = key;            
            o->values[o->length] = value;        
            o->length++;                            
            break;
        case MaArray:
            if (OFTEN_FALSE(o->length == o->capacity)) {
                o->capacity += o->capacity;
                arrayCapacityWindow = MAX(o->capacity, arrayCapacityWindow);                
                o->values = realloc(o->values, o->capacity);
            }
                        
            o->values[o->length++] = value;                                       
            break;
        default:
            break;
    }    
}

static inline void MaFree(MaObject* const o) {
    if (o != nil) {
        switch (o->type) {
            case MaHash:
                if (OFTEN_TRUE(o->keys != nil)) {
                    free(o->keys);
                    o->keys = nil;
                }
            case MaArray:
                if (OFTEN_TRUE(o->values != nil)) {
                    free(o->values);
                    o->values = nil;
                }                
            default:
                break;
        }            
    }    
}

@interface MaEnumerator : NSEnumerator
@end
@interface MaArrayWrapper: NSArray
- (id) initWithMaObject:(const MaObject*)obj andCore:(MaSONKit*)core;
@end
@interface MaDictionaryWrapper: NSDictionary
- (id) initWithMaObject:(const MaObject*)obj andCore:(MaSONKit*)core;
@end

inline static id NSObjectFromMaObject(const MaObject* o, MaSONKit* core) {
    
    if (OFTEN_FALSE(o == nil)) { return nil; }
        
    switch (o->type) {
        case MaNull:
            return nil;
        case MaTrue:
            return [NSNumber numberWithBool:YES];
        case MaFalse:   
            return [NSNumber numberWithBool:NO];
        case MaNumber: {
            NSString* num = [[NSString alloc] initWithBytesNoCopy:(char*)o->start length:o->length encoding:NSUTF8StringEncoding freeWhenDone:NO];
            if (OFTEN_FALSE([num rangeOfString:@"."].location == NSNotFound)) {
                return [NSNumber numberWithInt:[num intValue]];                                    
            } else {
                return [NSNumber numberWithDouble:[num doubleValue]];                                                    
            }            
        }
        case MaString: 
            return [[NSString alloc] initWithBytes:o->start length:o->length encoding:NSUTF8StringEncoding];
        case MaArray: 
            return [[MaArrayWrapper alloc] initWithMaObject:o andCore:core];
        case MaHash:  
            return [[MaDictionaryWrapper alloc] initWithMaObject:o andCore:core];
    }    
}

@implementation MaEnumerator { NSUInteger at;const MaObject* wrapped; MaSONKit* core; }
- (id) initWithMaObject:(const MaObject*)obj andCore:(MaSONKit*)c {
    if (self = [super init]) { at = 0; wrapped = obj; core = c; }
    return self;
}
- (id) nextObject {    
    switch (wrapped->type) {
        case MaArray: 
            return (at < wrapped->length) ? NSObjectFromMaObject(wrapped->values[at++], core) : nil;                                
        case MaHash:  
            return (at < wrapped->length) ? NSObjectFromMaObject(wrapped->keys[at++], core) : nil;                
        default:
            return nil;
    }    
}
@end

@implementation MaArrayWrapper { const MaObject* wrapped; MaSONKit* core; }
- (id) initWithMaObject:(const MaObject*)obj andCore:(MaSONKit*)c {
    if (self = [super init]) { wrapped = obj; core = c; }
    return self;
}
- (NSUInteger)count { return wrapped->length; }
- (id)objectAtIndex:(NSUInteger)index { return NSObjectFromMaObject(wrapped->values[index], core); }
@end

@implementation MaDictionaryWrapper { const MaObject* wrapped; MaSONKit* core; }
- (id) initWithMaObject:(const MaObject*)obj andCore:(MaSONKit*)c {
    if (self = [super init]) { wrapped = obj; core = c; }
    return self;
}
- (NSUInteger)count { return wrapped->length; }
- (NSEnumerator*) keyEnumerator { return [[MaEnumerator alloc] initWithMaObject:wrapped andCore:core]; }
- (id) objectForKey:(id)key {
    for (int i = 0; OFTEN_FALSE(i < wrapped->length); i++) {
        NSString* k = NSObjectFromMaObject(wrapped->keys[i], core);
        if (OFTEN_FALSE([k isEqualToString:key])) { return NSObjectFromMaObject(wrapped->values[i], core); }
    }
    return nil;
}
@end

static inline const char* fill(MaBuffer *buffer, register const char* bytes, register MaObject* const head) {
    
    MaObject* value = nil;    
    MaObject* key = nil;
    
    register NSUInteger len;    
    
    for (;;) {
        switch (*(++bytes)) { 
            case 0:
            case 93:
            case 125:
                return bytes;                
                
            case 34: 
                ++bytes;
                len = 0;
                
                for (;OFTEN_FALSE(*(bytes+len) != 34); len++) { 
                    if (OFTEN_FALSE(*(bytes+len)) == 92) { len++; } 
                    else if (OFTEN_FALSE(*(bytes+len) > 127)) { len++; if (OFTEN_FALSE(*(bytes+len) > 127)) { len++; if (OFTEN_FALSE(*(bytes+len) > 127)) { len += 2;} } }
                }
                
                if (key == nil && OFTEN_FALSE(head->type == MaHash)) {
                    key = MaStringMake(buffer, bytes, len);  
                    bytes += len;
                    for (;OFTEN_FALSE(*(++bytes) != 58););
                } else {
                    MaSet(head, key, MaStringMake(buffer, bytes, len)); 
                    bytes += len;
                    key = nil;
                }                                                
                
                break;  
                
            case 45:
            case 46:
            case 48:
            case 49:
            case 50:
            case 51:
            case 52:
            case 53:
            case 54:
            case 55:
            case 56:
            case 57: 
                len = 0;
                for (;OFTEN_FALSE(*(bytes + len) <= 57 && *(bytes + len) >= 45);len++);                                 
                MaSet(head, key, MaNumberMake(buffer, bytes, len));                  
                bytes += len-1;
                key = nil;
                break;   
                
            case 123:            
                value = MaHashMake(buffer);     
                MaSet(head, key, value);
                bytes = fill(buffer, bytes, value); 
                key = nil;
                break;            
                
            case 91: 
                value = MaArrayMake(buffer);
                MaSet(head, key, value);
                bytes = fill(buffer, bytes, value); 
                key = nil;
                break;                            
                
            case 110:
                bytes += 4;
                MaSet(head, key, (MaObject*)&MaNullObject);
                key = nil;
                break;
                
            case 116:
                bytes += 4;
                MaSet(head, key, (MaObject*)&MaTrueObject);
                key = nil;
                break;
                
            case 102:
                bytes += 5;
                MaSet(head, key, (MaObject*)&MaFalseObject);
                key = nil;
                break;                
        }        
    }    
}

@implementation MaSONKit {

    MaBuffer* buffer;    
    MaObject* root;    
    NSData* data;
}

- (id) initWithData:(NSData*)dat {
    
    if (self = [super init]) {
        buffer = MaBufferMake();
        root = MaHashMake(buffer); 
        data = dat;
        
        const char* bytes = (const char*)[data bytes];
        
        for (;*bytes != '{';bytes++);
        
        fill(buffer, bytes, root);  
        
    }
    return self;
}

- (void) clear {
    if (root != nil) {
        MaFree(root);
        root = nil;        
    }
    
    if (buffer != nil) {
        for (int i=0;i<buffer->count;i++) {
            if (buffer->pages[i] != nil) {
                free(buffer->pages[i]);
                buffer->pages[i] = nil;
            }
        }
        if (buffer->pages != nil) {
            free(buffer->pages); 
            buffer->pages = nil;
        }
        free(buffer);
        buffer = nil;        
    }
    
}

- (void) dealloc { [self clear]; }

- (NSDictionary*) wrap { return [[MaDictionaryWrapper alloc] initWithMaObject:root andCore:self]; }

+ (NSDictionary*) parse:(NSData*)data { return [[[MaSONKit alloc] initWithData:data] wrap]; }


@end


