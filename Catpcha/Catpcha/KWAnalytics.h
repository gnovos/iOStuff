//
//  KWAnalytics.h
//  Catpcha
//
//  Created by Mason on 11/19/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//


@interface KWAnalytics : NSObject

+ (NSString*) deviceID;

+ (void) init;
+ (void) checkpoint:(NSString*)checkpoint;
+ (void) launchFeedback;

+ (void) flurry:(NSString*)name event:(id)event;
+ (void) flurry:(NSString*)name event:(id)event block:(NSDictionary*(^)(void))block;
+ (void) flurryLocation;

@end
