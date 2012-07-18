//
//  MZStroke.m
//  EraseSomething
//
//  Created by Mason on 7/2/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZStroke.h"

@implementation MZStroke

- (void) encodeWithCoder:(NSCoder*)coder {
    [coder encodeCGPoint:self.start forKey:@"start"];
    [coder encodeCGPoint:self.end forKey:@"end"];
    
    [coder encodeFloat:self.red forKey:@"red"];
    [coder encodeFloat:self.green forKey:@"green"];
    [coder encodeFloat:self.blue forKey:@"blue"];
    [coder encodeFloat:self.alpha forKey:@"alpha"];
    
    [coder encodeObject:self.brush forKey:@"brush"];
    
    [coder encodeObject:self.added forKey:@"added"];
}

- (id) initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) {
        self.start = [decoder decodeCGPointForKey:@"start"];
        self.end = [decoder decodeCGPointForKey:@"end"];
        
        self.red = [decoder decodeFloatForKey:@"red"];
        self.green = [decoder decodeFloatForKey:@"green"];
        self.blue = [decoder decodeFloatForKey:@"blue"];
        self.alpha = [decoder decodeFloatForKey:@"alpha"];
        
        self.brush = [decoder decodeObjectForKey:@"brush"];
        
        self.added = [decoder decodeObjectForKey:@"added"];
    }
    return self;
}


@end
