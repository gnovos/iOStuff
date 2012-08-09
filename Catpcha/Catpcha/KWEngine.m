//
//  KWEngine.m
//  Catpcha
//
//  Created by Mason Glaves on 7/16/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWEngine.h"
#import "KWClient.h"
#import "KWBasket.h"
#import "KWLevel.h"
#import "KWKitten.h"
#import "KWYarn.h"
#import "KWMouse.h"

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

typedef struct {
    unsigned short seq;
    unsigned char type;
    NSUInteger clientid;
    NSTimeInterval timestamp;
} KWPacketHeader;

typedef struct {
    KWPacketHeader header;
    void* payload;
} KWPacket;


@interface KWEngine ()

@property (nonatomic, strong) NSString* playerID;
@property (nonatomic, strong) NSMutableDictionary* achievements;

@end

@implementation KWEngine {        
    CADisplayLink* loop;
    NSTimeInterval last;
    NSMutableDictionary* handlers;
    
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
        level = [[KWLevel alloc] initLevel:1 withSize:UIScreen.mainScreen.bounds.size];
        [level populate];
        handlers = [[NSMutableDictionary alloc] init];
        master = 0;        
    }
    return self;    
}

- (void) setPeers:(NSArray*)peers {
    clients = [[NSMutableDictionary alloc] initWithCapacity:peers.count + 1];
    [clients setObject:[[KWClient alloc] initWithClientID:self.playerID.hash] forKey:@(self.playerID.hash)];
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
        
        level = [[KWLevel alloc] initLevel:level.level + 1 withSize:UIScreen.mainScreen.bounds.size];
        [level populate];
        
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
    
    NSMutableData* data = [[NSMutableData alloc] initWithBytes:&packet.header length:sizeof(KWPacketHeader)];
    
    switch (packet.header.type) {
        case KWPacketTypePong:
            [data appendBytes:&packet.payload length:sizeof(KWPongPayload)];
            break;
        case KWPacketTypeNomination:
            [data appendBytes:&packet.payload length:sizeof(KWNominationPayload)];
            break;
        case KWPacketTypeVote:
            [data appendBytes:&packet.payload length:sizeof(KWVotePayload)];
            break;
        case KWPacketTypeLayout:
            [data appendBytes:&packet.payload length:sizeof(KWLayoutPayload)];
            KWLayoutPayload* layout = packet.payload;
            for (int i = 0; i < layout->count; i++) {
                [data appendBytes:&layout->layouts[i] length:sizeof(KWObjectLayout)];
            }
            break;
        case KWPacketTypeEvent:
            [data appendBytes:&packet.payload length:sizeof(KWEventPayload)];
            break;
    }
    //xxx send data
    [self discardPacket:packet];
}

- (KWPacket) packet:(KWPacketType)type, ... {
    
    KWPacketHeader header;
    void* payload;
    
    static unsigned short seq = 0;
    
    header.timestamp = [[NSDate date] timeIntervalSince1970];
    header.type = type;
    header.seq = seq++;
    header.clientid = self.playerID.hash;
    
    va_list args;
    va_start(args, type);
    
    switch (type) {
        case KWPacketTypePing:
            break;
        case KWPacketTypePong: {
            payload = malloc(sizeof(KWPongPayload));
            KWPongPayload* pong = payload;
            pong->pingid = va_arg(args, NSUInteger);
            pong->pingtime = va_arg(args, double);
            break;
        }
        case KWPacketTypeNomination: {
            payload = malloc(sizeof(KWNominationPayload));
            KWNominationPayload* nomination = payload;
            nomination->candidate = va_arg(args, NSUInteger);
            nomination->pingtime = va_arg(args, double);
            break;
        }
        case KWPacketTypeVote: {
            payload = malloc(sizeof(KWVotePayload));
            KWVotePayload* vote = payload;
            vote->master = va_arg(args, NSUInteger);
            break;
        }
        case KWPacketTypeLayout: {
            payload = malloc(sizeof(KWLayoutPayload));
            KWLayoutPayload* layout = payload;
            layout->level = va_arg(args, NSUInteger);
            layout->size = va_arg(args, CGSize);
            
            NSArray* objects = va_arg(args, NSArray*);
            layout->count = objects.count;
            
            KWObjectLayout* layouts = malloc(sizeof(KWObjectLayout) * objects.count);
            layout->layouts = layouts;
            [objects enumerateObjectsUsingBlock:^(KWObject* obj, NSUInteger idx, BOOL *stop) {
                KWObjectLayout* layout = &layouts[idx];
                layout->oid = obj.oid;
                layout->type = obj.type;
                layout->bounds = obj.bounds;
            }];
            
            break;
        }
        case KWPacketTypeEvent: {
            payload = malloc(sizeof(KWEventPayload));
            //xxx
            break;
        }
            
        default:
            break;
    }
    
    va_end(args);
    
    return (KWPacket){ header, payload };
}

- (void) ping { [self send:[self packet:KWPacketTypePing]]; }

- (void) handle:(NSData*)data {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    void* packet;
    
    [data getBytes:&packet length:data.length];
    
    KWPacketHeader* header = (KWPacketHeader*)packet;
    packet += sizeof(KWPacketHeader);
    
    KWClient* client = [clients objectForKey:@(header->clientid)];
    
    switch (header->type) {
        case KWPacketTypePing: {
            [self send:[self packet:KWPacketTypePong, header->seq, now - header->timestamp]];
            break;
        }
            
        case KWPacketTypePong: {
            KWPongPayload* pong = packet;
            [client.pings addObject:@(pong->pingtime)];
            [client.pings addObject:@(now - header->timestamp)];
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
                
                [self send:[self packet:KWPacketTypeNomination, candidate, best]];
            }
            break;
        }
            
        case KWPacketTypeNomination: {
            KWNominationPayload* nomination = packet;
            KWClient* nominated = [clients objectForKey:@(nomination->candidate)];
            [nominated.nominations addObject:@(nomination->pingtime)];
            
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
                
                [self send:[self packet:KWPacketTypeVote, master]];
            }
            break;
        }
            
        case KWPacketTypeVote: {
            KWVotePayload* vote = packet;
            client.voted = YES;
            if (master && master != vote->master) {
                //xxx we disagree, so revote
            }
            master = vote->master;
            
            BOOL allVoted = [[clients.allValues valueForKeyPath:@"@sum.voted"] integerValue] == clients.count;
            
            if (allVoted && master == self.playerID.hash) {
                [self send:[self packet:KWPacketTypeLayout, level.level, level.bounds.size, level.objects]];
            }
            
            break;
        }
            
        case KWPacketTypeLayout: {
            KWLayoutPayload* layout = packet;
            NSUInteger count = layout->count;

            KWLevel* lvl = [[KWLevel alloc] initLevel:layout->level withSize:layout->size];
            
            packet += sizeof(KWLayoutPayload);
            layout->layouts = packet;
            
            for (int i = 0; i < count; i++) {
                KWObjectLayout* olayout = &layout->layouts[i];
                KWObject* obj = nil;
                
                switch (olayout->type) {
                    case KWObjectTypeBasket:
                        obj = [[KWBasket alloc] initWithLevel:lvl];
                        break;
                    case KWObjectTypeKitten:
                        obj = [[KWKitten alloc] initWithLevel:lvl];
                        break;
                    case KWObjectTypeMouse:
                        obj = [[KWMouse alloc] initWithLevel:lvl];
                        break;
                    case KWObjectTypeYarn:
                        obj = [[KWYarn alloc] initWithLevel:lvl];
                        break;
                }
                
                obj.oid = olayout->oid;
                obj.bounds = olayout->bounds;
                
                [lvl addObject:obj];
            }
            
            level = lvl;
            
            break;
        }
            
        case KWPacketTypeEvent: {
            //xxx
            break;
        }
    }
    
}


@end
