//
//  KWEngine.h
//  KittenWrangler
//
//  Created by Mason Glaves on 7/16/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KWLevel;

@interface KWEngine : NSObject

@property (nonatomic, readonly, strong) KWLevel* level;

- (void) start;
- (void) stop;
- (void) pause;


@end
