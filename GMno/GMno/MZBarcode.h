//
//  MZUPCLookup.h
//  GMno
//
//  Created by Mason Glaves on 3/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMZAPIKEY @"82760dd501710ab053f6f3c519c10afb"
#define kMZAPIURL @"http://www.upcdatabase.org/api/json/"

@interface MZBarcode : NSObject

@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) NSString* price;

+ (void) lookup:(NSString*)code withCompletion:(void(^)(MZBarcode* code))completion;

@end
