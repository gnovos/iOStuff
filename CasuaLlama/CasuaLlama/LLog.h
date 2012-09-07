//
//  LLog.h
//  CasuaLlama
//
//  Created by Mason on 9/7/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#define tlog(fmt, ...) TFLog(@"%s [%d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define loginfo(fmt, ...)    DDLogInfo   (@"%s [%d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define logwarn(fmt, ...)    DDLogWarn   (@"%s [%d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define logerror(fmt, ...)   DDLogError  (@"%s [%d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define logverbose(fmt, ...) DDLogVerbose(@"%s [%d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#ifdef DEBUG
#	define dlog(fmt, ...) loginfo   (fmt, ##__VA_ARGS__)
#   define vlog(fmt, ...) logverbose(fmt, ##__VA_ARGS__)
#   define wlog(fmt, ...) logwarn   (fmt, ##__VA_ARGS__)
#   define elog(err)      if(err)   logerror(@"[ERROR] %@", err)

#   define ulog(fmt, ...) \
UIAlertView* alert = [[UIAlertView alloc] \
initWithTitle:[NSString stringWithFormat:@"%s\n [line %d] ", __PRETTY_FUNCTION__, __LINE__] \
message:[NSString stringWithFormat:fmt, ##__VA_ARGS__] \
delegate:nil \
cancelButtonTitle:@"Ok" \
otherButtonTitles:nil]; \
[alert show]; \

#else
#   define vlog(fmt, ...) tlog(fmt, ##__VA_ARGS__)
#   define wlog(fmt, ...) tlog(fmt, ##__VA_ARGS__)
#   define elog(err)      tlog(@"[ERROR] %@", err)
#   define dlog(fmt, ...) tlog(fmt, ##__VA_ARGS__)
#   define ulog(fmt, ...) tlog(fmt, ##__VA_ARGS__)
#endif

#define dlogine      dlog(@"*")

#define dlogobj(o)   dlog(#o @"=%@", o)
#define dlogptr(p)   dlog(#p @"=%p", p)
#define dlogint(i)   dlog(#i @"=%d", i)
#define dlogfloat(f) dlog(#f @"=%f", f)

#define dlogrect(r)  dlog(#r @"={{%f,%f},{%f,%f}}", r.origin.x, r.origin.y, r.size.width, r.size.height)
#define dlogsize(s)  dlog(#s @"={%f,%f}", s.width, s.height)
#define dlogpoint(p) dlog(#p @"={%f,%f}", p.x, p.y)


@interface LLog : NSObject



@end
