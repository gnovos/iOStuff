//
//  KWLog.h
//  KittenWrangler
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#ifndef KittenWrangler_KWLog_h
#define KittenWrangler_KWLog_h

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

#define dobj(o)   dlog(#o @"=%@", o)
#define dptr(p)   dlog(#p @"=%p", p)
#define dint(i)   dlog(#i @"=%d", i)
#define dfloat(f) dlog(#f @"=%f", f)

#define drect(r)  dlog(#r @"={{%f,%f},{%f,%f}}", r.origin.x, r.origin.y, r.size.width, r.size.height)
#define dsize(s)  dlog(#s @"={%f,%f}", s.width, s.height)
#define dpoint(p) dlog(#p @"={%f,%f}", p.x, p.y)


#endif
