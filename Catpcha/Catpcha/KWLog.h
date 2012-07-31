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

#ifdef DEBUG
#	define dlog(fmt, ...) alog(fmt, ##__VA_ARGS__);
#   define elog(err) { if(err) olog(err) }
#   define ulog(fmt, ...)   { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:\
[NSString stringWithFormat:@"%s\n [line %d] ", __PRETTY_FUNCTION__, __LINE__] \
message:[NSString stringWithFormat:fmt, ##__VA_ARGS__] \
delegate:nil \
cancelButtonTitle:@"Ok" \
otherButtonTitles:nil]; \
[alert show]; \
}
#else
#   define dlog(...)
#   define elog(...)
#   define ulog(...)
#endif

#define dline     dlog(@".")

#define dlobj(o)   dlog(#o @"=%@", o)
#define dlptr(p)   dlog(#p @"=%p", p)
#define dlint(i)   dlog(#i @"=%d", i)
#define dlfloat(f) dlog(#f @"=%f", f)

#define dlrect(r)  dlog(#r @"={{%f,%f},{%f,%f}}", r.origin.x, r.origin.y, r.size.width, r.size.height)
#define dlsize(s)  dlog(#s @"={%f,%f}", s.width, s.height)
#define dlpoint(p) dlog(#p @"={%f,%f}", p.x, p.y)


#endif
