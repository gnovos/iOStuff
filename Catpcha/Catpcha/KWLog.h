//
//  KWLog.h
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#ifndef Catpcha_KWLog_h
#define Catpcha_KWLog_h

#define alog(fmt, ...) NSLog(@"%s [%d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define tlog(fmt, ...) TFLog(@"%s [%d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#ifdef DEBUG
#	define dlog(fmt, ...) alog   (fmt, ##__VA_ARGS__);
#   define vlog(fmt, ...) alog(fmt, ##__VA_ARGS__);
#   define wlog(fmt, ...) alog   (fmt, ##__VA_ARGS__);
#   define elog(err)      if(err)   alog(@"[ERROR] %@", err);

#   define ulog(fmt, ...) \
UIAlertView* alert = [[UIAlertView alloc] \
initWithTitle:[NSString stringWithFormat:@"%s\n [line %d] ", __PRETTY_FUNCTION__, __LINE__] \
message:[NSString stringWithFormat:fmt, ##__VA_ARGS__] \
delegate:nil \
cancelButtonTitle:@"Ok" \
otherButtonTitles:nil]; \
[alert show]; \

#else
#   define vlog(fmt, ...) tlog(fmt, ##__VA_ARGS__);
#   define wlog(fmt, ...) tlog(fmt, ##__VA_ARGS__);
#   define elog(err)      tlog(@"[ERROR] %@", err);
#   define dlog(fmt, ...) tlog(fmt, ##__VA_ARGS__);
#   define ulog(fmt, ...) tlog(fmt, ##__VA_ARGS__);
#endif

#define dlogline      dlog(@"*");

#define dlogobj(o)   dlog(#o @"=%@", o)
#define dlogptr(p)   dlog(#p @"=%p", p)
#define dlogint(i)   dlog(#i @"=%d", i)
#define dlogfloat(f) dlog(#f @"=%f", f)

#define dlogrect(r)  dlog(#r @"={{%f,%f},{%f,%f}}", r.origin.x, r.origin.y, r.size.width, r.size.height)
#define dlogsize(s)  dlog(#s @"={%f,%f}", s.width, s.height)
#define dlogpoint(p) dlog(#p @"={%f,%f}", p.x, p.y)


#endif
