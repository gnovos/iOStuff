//
//  MZDrawing.m
//  EraseSomething
//
//  Created by Mason on 6/25/12.
//  Copyright (c) 2012 Mason. All rights reserved.
//

#import "MZDrawing.h"
#import "MZStroke.h"

@implementation MZDrawing {
    NSMutableArray* strokes;
}

- (void) encodeWithCoder:(NSCoder*)coder { [coder encodeObject:strokes forKey:@"strokes"]; }
- (id) initWithCoder:(NSCoder*)decoder { if (self = [super init]) { strokes = [decoder decodeObjectForKey:@"strokes"]; } return self; }
- (id) init { if (self = [super init]) { strokes = [NSMutableArray array]; } return self; }

- (void) playback {
    
//    [strokes enumerateObjectsUsingBlock:^(MZStroke* stroke, NSUInteger idx, BOOL *stop) {
//        //render the line
//        [stroke.added t]
//    }];
//	
//	// Render the current path
//	for(i = 0; i < count - 1; ++i, ++point)
//		[self renderLineFromPoint:*point toPoint:*(point + 1)];
//	
//	// Render the next path after a short delay
//	[recordedPaths removeObjectAtIndex:0];
//	if([recordedPaths count])
//		[self performSelector:@selector(playback:) withObject:recordedPaths afterDelay:0.01];
}


@end
