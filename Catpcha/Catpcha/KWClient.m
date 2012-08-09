//
//  KWClient.m
//  Catpcha
//
//  Created by Mason on 8/9/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWClient.h"

@implementation KWClient 

- (id) initWithClientID:(NSUInteger)client {
    if (self = [super init]) {
        _clientID = client;
        _pings = [[NSMutableArray alloc] init];
        _nominations = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
