//
//  KWClient.h
//  Catpcha
//
//  Created by Mason on 8/9/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWClient : NSObject

@property (nonatomic, readonly, assign) NSUInteger clientID;

@property (nonatomic, assign) BOOL voted;
@property (nonatomic, strong) NSMutableArray* pings;
@property (nonatomic, strong) NSMutableArray* nominations;

- (id) initWithClientID:(NSUInteger)client;

@end
