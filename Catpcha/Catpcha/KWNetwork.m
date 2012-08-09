//
//  KWData.m
//  Catpcha
//
//  Created by Mason on 8/8/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWNetwork.h"

typedef enum {
    KWPacketTypePing,
    KWPacketTypePong,
    KWPacketTypeNomination,
    KWPacketTypeVote,
} KWPacketType;

typedef struct {
} KWPingPacket;

typedef struct {
    unsigned short ping;
    NSTimeInterval pingtime;
} KWPongPacket;

typedef struct {
    NSUInteger clientid;
    unsigned short pingtime;
} KWNominationPacket;

typedef struct {
    NSUInteger master;
} KWVotePacket;

typedef struct {
    unsigned char oid;
    unsigned char type;
    CGSize size;
    CGPoint location;
} KWObjectLayout;

typedef struct {
    NSUInteger level;
    CGSize size;
    NSUInteger count;
    struct {
        unsigned char oid;
        unsigned char type;
        CGSize size;
        CGPoint location;
    } objects[256];
} KWLevelPacket;

typedef struct {
    unsigned char oid;
    CGFloat heading;
    CGPoint position;
    short velocity;
    unsigned char state;
} KWObjectPacket;

typedef struct {
    unsigned short seq;
    unsigned char type;
    NSUInteger clientid;
    NSTimeInterval timestamp;
    union {
        KWPingPacket ping;
        KWPongPacket pong;
        KWNominationPacket nomination;
        KWVotePacket vote;
    } data;
} KWPacket;

static inline KWPacket KWPacketMake(KWPacketType type) {
    KWPacket packet;
    
    static unsigned short seq = 0;
    
    packet.timestamp = [[NSDate date] timeIntervalSince1970];
    packet.type = type;
    packet.seq = seq++;
    //xxx set client id properly
    
    return packet;
}

@implementation KWNetwork {
    NSUInteger master;
}

- (id) init {
    if (self = [self init]) {
    }
    return self;
}

- (void) handle:(NSData*)data {
    
    KWPacket packet;
    
    [data getBytes:&packet length:sizeof(packet)];
    
    switch (packet.type) {
        case KWPacketTypePing: {
            NSTimeInterval nowts = [[NSDate date] timeIntervalSince1970];
            KWPacket pong = KWPacketMake(KWPacketTypePong);
            pong.data.pong.ping = packet.seq;
            pong.data.pong.pingtime = nowts - packet.timestamp;
            [self send:pong];
            break;
        }
            
        case KWPacketTypePong: {
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval avgping = (packet.data.pong.pingtime + (now - packet.timestamp)) / 2.0f;
            //xxx put into pings array (of dictionaries)
            BOOL fullPings = YES;
            if (fullPings) {
                NSArray* pings;
                NSUInteger clientid = [[[[pings sortedArrayUsingComparator:^(NSDictionary* a, NSDictionary* b) {
                    NSTimeInterval aping = [[a valueForKey:@"pingtime"] doubleValue];
                    NSTimeInterval bping = [[b valueForKey:@"pingtime"] doubleValue];
                    return aping == bping ? NSOrderedSame : aping > bping ? NSOrderedAscending : NSOrderedDescending;
                }] lastObject] valueForKey:@"clientid"] unsignedIntegerValue];
                
                KWPacket nomination = KWPacketMake(KWPacketTypeNomination);
                nomination.data.nomination.pingtime = avgping;
                nomination.data.nomination.clientid = clientid;
                [self send:nomination];
            }
            break;
        }
            
        case KWPacketTypeNomination: {
            //xxx store nominations as they come in;
            BOOL fullNoms = YES;
            if (fullNoms) {
                NSArray* nominations;
                NSUInteger clientid = [[[[nominations sortedArrayUsingComparator:^(NSDictionary* a, NSDictionary* b) {
                    NSTimeInterval aping = [[a valueForKey:@"pingtime"] doubleValue];
                    NSTimeInterval bping = [[b valueForKey:@"pingtime"] doubleValue];
                    return aping == bping ? NSOrderedSame : aping > bping ? NSOrderedAscending : NSOrderedDescending;
                }] lastObject] valueForKey:@"clientid"] unsignedIntegerValue];
                
                KWPacket vote = KWPacketMake(KWPacketTypeVote);
                vote.data.vote.master = clientid;
                [self send:vote];
            }
            break;
        }
            
        case KWPacketTypeVote: {
            if (master && master != packet.data.vote.master) {
                //xxx we disagree, so revote
            }
            master = packet.data.vote.master;
            //xxx after we have enough votes, play on!
            break;
        }
    }
    
    //return packet?
}

- (void) ping {
    KWPacket ping = KWPacketMake(KWPacketTypePing);
    [self send:ping];
}


- (void) send:(KWPacket)packet {
    //xxx 
}

@end
