//
//  MZBrush.m
//  EraseSomething
//
//  Created by Mason on 7/2/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZBrush.h"

@implementation MZBrush {
    NSString* image;
}

- (void)encodeWithCoder:(NSCoder*)coder {    
    [coder encodeObject:image forKey:@"image"];
}

- (id)initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) { image = [decoder decodeObjectForKey:@"image"]; }
    return self;
}


@end
