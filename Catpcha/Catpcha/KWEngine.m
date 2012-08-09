//
//  KWEngine.m
//  Catpcha
//
//  Created by Mason Glaves on 7/16/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWEngine.h"
#import "KWBasket.h"
#import "KWKitten.h"
#import "KWLevel.h"
#import "KWClient.h"

typedef enum {
    KWPacketTypePing,
    KWPacketTypePong,
    KWPacketTypeNomination,
    KWPacketTypeVote,
    KWPacketTypeLayout,
    KWPacketTypeEvent,
} KWPacketType;

typedef struct {
    unsigned short pingid;
    NSTimeInterval pingtime;
} KWPongPayload;

typedef struct {
    NSUInteger candidate;
    unsigned short pingtime;
} KWNominationPayload;

typedef struct {
    NSUInteger master;
} KWVotePayload;

typedef struct {
    unsigned char oid;
    unsigned char type;
    CGRect bounds;
} KWObjectLayout;

typedef struct {
    NSUInteger level;
    CGSize size;
    NSUInteger count;
    KWObjectLayout* layouts;
} KWLayoutPayload;

typedef struct {
    unsigned char type;
    void* event;
} KWEventPayload;

typedef struct {
    unsigned char oid;
    CGFloat heading;
    CGPoint position;
    short velocity;
    unsigned char state;
} KWObjectMotionEvent;

typedef union {
    KWPongPayload* pong;
    KWNominationPayload* nomination;
    KWVotePayload* vote;
    KWLayoutPayload* layout;
    KWEventPayload* event;
} KWPayload;

typedef struct {
    unsigned short seq;
    unsigned char type;
    NSUInteger clientid;
    NSTimeInterval timestamp;
    KWPayload payload;
} KWPacket;

@interface KWEngine ()

@property (nonatomic, strong) NSString* playerID;
@property (nonatomic, strong) NSMutableDictionary* achievements;

@end

@implementation KWEngine {        
    CADisplayLink* loop;
    NSTimeInterval last;
    NSMutableDictionary* handlers;
    
    NSUInteger clientid;
    NSUInteger master;
    NSMutableDictionary* clients;    
}

@synthesize level;

+ (id) instance {
    static KWEngine* engine;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ engine = [[KWEngine alloc] init]; });
    return engine;
}

- (id) init {
    if (self = [super init]) {
        level = [[KWLevel alloc] initLevel:1];
        handlers = [[NSMutableDictionary alloc] init];
        master = 0;        
    }
    return self;    
}

- (void) setPeers:(NSArray*)peers {
    clients = [[NSMutableDictionary alloc] initWithCapacity:peers.count];
    [peers enumerateObjectsUsingBlock:^(NSObject* peer, NSUInteger idx, BOOL *stop) {
        [clients setObject:[[KWClient alloc] initWithClientID:peer.hash] forKey:@(peer.hash)];
    }];    
}

- (void) start:(BOOL)paused {
    if (loop == nil) {
        loop = [CADisplayLink displayLinkWithTarget:self selector:@selector(loop:)];
        
        [loop addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        loop.paused = paused;
    }
}

- (void) stop { [loop invalidate]; loop = nil; }
- (void) pause { loop.paused = YES; }
- (void) unpause { loop.paused = NO; }

- (void) loop:(CADisplayLink*)link {
    
    NSTimeInterval elapsed = link.timestamp - last;
    
    [KWGFX animate:elapsed animation:^{
        [level tick:elapsed];
        [[handlers objectForKey:@(KWEngineEventTick)] enumerateObjectsUsingBlock:^(void(^handler)(id dt), NSUInteger idx, BOOL *stop) {
            handler(@(elapsed));
        }];
    } onComplete:nil];
            
    last = link.timestamp;
    
    if (level.complete) {
        [[handlers objectForKey:@(KWEngineEventLevelComplete)] enumerateObjectsUsingBlock:^(void(^handler)(id level), NSUInteger idx, BOOL *stop) {
            handler(level);
        }];
        
        level = [[KWLevel alloc] initLevel:level.level + 1];
        
        [[handlers objectForKey:@(KWEngineEventLevelBegin)] enumerateObjectsUsingBlock:^(void(^handler)(id level), NSUInteger idx, BOOL *stop) {
            handler(level);
        }];
    }
}

- (void) attach:(id)target forEvent:(KWEngineEvent)event withHandler:(void(^)(id target, id data))handler {
    __weak id t = target;
    NSMutableArray* h = [handlers objectForKey:@(event)];
    if (h == nil) {
        h = [[NSMutableArray alloc] init];
        [handlers setObject:h forKey:@(event)];
    }
    [h addObject:[^(id data){ handler(t, data); } copy]];
}

- (GKAchievement*) achievement:(NSString*)ident {
    
    GKAchievement* achievement = [self.achievements objectForKey:ident];
    if (!achievement) {
        achievement = [[GKAchievement alloc] initWithIdentifier:ident];
        achievement.showsCompletionBanner = YES;
        achievement.percentComplete = 0;
    }
    
    return achievement;
}

- (void) save {
    [GKAchievement reportAchievements:self.achievements.allValues withCompletionHandler:^(NSError *error) {
        elog(error);
    }];
}

- (void) loadPlayer:(void(^)(void))success {
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray* achievements, NSError *error) {
        elog(error);
        self.achievements = [[NSMutableDictionary alloc] init];
        [achievements enumerateObjectsUsingBlock:^(GKAchievement* achievement, NSUInteger idx, BOOL *stop) {
            [self.achievements setObject:achievement forKey:achievement.identifier];
        }];
        success();
    }];
}

//- (void) score {
//    GKLeaderboard* board = [GKLeaderboard ]
//loadCategoriesWithCompletionHandler:(void (^)(NSArray *categories, NSArray *titles, NSError *error))completionHandler
//    MEOW_LEADERBOARD_KITCOUNT
//}

- (void) reportScore:(int64_t)score forCategory:(NSString*)board {
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:board];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) { elog(error); }];
}

- (void) authenticate:(void(^)(void))success failure:(void(^)(void))failure {
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    if (gcClass && osVersionSupported) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        self.playerID = localPlayer.isAuthenticated ? localPlayer.playerID : nil;
        if (self.playerID) {
            [self loadPlayer:success];
        } else {
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
                self.playerID = localPlayer.isAuthenticated ? localPlayer.playerID : nil;
                if (self.playerID) {
                    [self loadPlayer:success];
                } else {
                    failure();
                }
            }];
        }
    } else {
        failure();
    }
}


- (void) discardPacket:(KWPacket)packet {
    //xxx
}

- (void) send:(KWPacket)packet {
    //xxx
    [self discardPacket:packet];
}

- (KWPacket) createPacket:(KWPacketType)type, ... {
    
    KWPacket packet;
    
    static unsigned short seq = 0;
    
    packet.timestamp = [[NSDate date] timeIntervalSince1970];
    packet.type = type;
    packet.seq = seq++;
    packet.clientid = clientid;
    
    va_list args;
    va_start(args, type);
    
    switch (type) {
        case KWPacketTypePing:
            break;
        case KWPacketTypePong: {
            packet.payload.pong = malloc(sizeof(KWPongPayload));
            packet.payload.pong->pingid = va_arg(args, NSUInteger);
            packet.payload.pong->pingtime = va_arg(args, double);
            break;
        }
        case KWPacketTypeNomination: {
            packet.payload.nomination = malloc(sizeof(KWNominationPayload));
            packet.payload.nomination->candidate = va_arg(args, NSUInteger);
            packet.payload.nomination->pingtime = va_arg(args, double);
            break;
        }
        case KWPacketTypeVote: {
            packet.payload.vote = malloc(sizeof(KWVotePayload));
            packet.payload.vote->master = va_arg(args, NSUInteger);
            break;
        }
        case KWPacketTypeLayout: {
            packet.payload.layout = malloc(sizeof(KWLayoutPayload));
            packet.payload.layout->level = va_arg(args, NSUInteger);
            packet.payload.layout->size = va_arg(args, CGSize);
            
            NSArray* objects = va_arg(args, NSArray*);
            packet.payload.layout->count = objects.count;
            
            KWObjectLayout* layouts = malloc(sizeof(KWObjectLayout) * objects.count);
            packet.payload.layout->layouts = layouts;
            [objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
                KWObjectLayout* layout = &layouts[idx];
                layout->oid = obj.oid;
                layout->type = obj.type;
                layout->bounds = obj.bounds;
            }];
            
            break;
        }
        case KWPacketTypeEvent: {
            packet.payload.event = malloc(sizeof(KWEventPayload));
            //xxx
            break;
        }
            
        default:
            break;
    }
    
    va_end(args);
    
    
    return packet;
}

- (void) ping { [self send:[self createPacket:KWPacketTypePing]]; }

- (void) handle:(NSData*)data {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    KWPacket packet;
    
    [data getBytes:&packet length:sizeof(packet)];
    
    KWClient* client = [clients objectForKey:@(packet.clientid)];
    
    switch (packet.type) {
        case KWPacketTypePing: {
            [self send:[self createPacket:KWPacketTypePong, packet.seq, now - packet.timestamp]];
            break;
        }
            
        case KWPacketTypePong: {
            [client.pings addObject:@(packet.payload.pong->pingtime)];
            [client.pings addObject:@(now - packet.timestamp)];
            __block BOOL enough = YES;
            [[clients allValues] enumerateObjectsUsingBlock:^(KWClient* c, NSUInteger idx, BOOL *stop) {
                if (c.pings.count < 6.0f) {
                    enough = NO;
                }
            }];
            
            if (enough) {
                __block KWClient* candidate = nil;
                __block NSTimeInterval best = now;
                [[clients allValues] enumerateObjectsUsingBlock:^(KWClient* c, NSUInteger idx, BOOL *stop) {
                    __block NSTimeInterval avg = [[c.pings valueForKeyPath:@"@avg.self"] doubleValue];
                    if (avg < best) {
                        candidate = c;
                        best = avg;
                    }
                }];
                
                [candidate.nominations addObject:@(best)];
                
                [self send:[self createPacket:KWPacketTypeNomination, candidate, best]];
            }
            break;
        }
            
        case KWPacketTypeNomination: {
            KWClient* nominated = [clients objectForKey:@(packet.payload.nomination->candidate)];
            [nominated.nominations addObject:@(packet.payload.nomination->pingtime)];
            
            __block NSUInteger ncount = 0;
            [clients.allValues enumerateObjectsUsingBlock:^(KWClient* c, NSUInteger idx, BOOL *stop){
                ncount += c.nominations.count;
            }];
            
            if (ncount == clients.count) {
                __block NSUInteger votes = 0;
                __block NSTimeInterval best = now;
                __block NSUInteger fastest = 0;
                [clients.allValues enumerateObjectsUsingBlock:^(KWClient* c, NSUInteger idx, BOOL *stop) {
                    if (c.nominations.count > votes) {
                        votes = c.nominations.count;
                        master = c.clientID;
                    } else if (c.nominations.count == votes) {
                        master = 0;
                    }
                    NSTimeInterval avg = [[c.nominations valueForKeyPath:@"@avg.self"] doubleValue];
                    if (avg < best) {
                        best = avg;
                        fastest = c.clientID;
                    }
                }];
                
                if (master == 0) {
                    master = fastest;
                }
                
                [self send:[self createPacket:KWPacketTypeVote, master]];
            }
            break;
        }
            
        case KWPacketTypeVote: {
            client.voted = YES;
            if (master && master != packet.payload.vote->master) {
                //xxx we disagree, so revote
            }
            master = packet.payload.vote->master;
            
            if ([[clients.allValues valueForKeyPath:@"@sum.voted"] integerValue] == clients.count) {
                KWLevel* level; //xxx
                [self send:[self createPacket:KWPacketTypeLayout, level.level, level.bounds.size, level.objects]];
            }
            
            break;
        }
            
        case KWPacketTypeLayout: {
            //xxx unpack level
            break;
        }
            
        case KWPacketTypeEvent: {
            break;
        }
    }
    
    //return packet?
}


@end
