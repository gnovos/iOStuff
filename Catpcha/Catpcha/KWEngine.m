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

@interface KWEngine ()

@property (nonatomic, strong) NSString* playerID;
@property (nonatomic, strong) NSMutableDictionary* achievements;

@end

@implementation KWEngine {        
    CADisplayLink* loop;
    NSTimeInterval last;
    NSMutableDictionary* handlers;
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
    }
    return self;    
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


@end
