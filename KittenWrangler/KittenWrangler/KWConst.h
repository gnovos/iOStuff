//
//  KWConst.h
//  KittenWrangler
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#ifndef KittenWrangler_KWConst_h
#define KittenWrangler_KWConst_h

static const CGFloat kKWAngle0Degrees   = 0.0f;
static const CGFloat kKWAngle45Degrees  = 45.0f;
static const CGFloat kKWAngle90Degrees  = 90.0f;
static const CGFloat kKWAngle180Degrees = 180.0f;
static const CGFloat kKWAngle270Degrees = 270.0f;
static const CGFloat kKWAngle360Degrees = 360.0f;

static const CGFloat kKWKittenInterest  = 0.5f;

#define KWCGRectCenter(x) CGPointMake(CGRectGetMidX(x), CGRectGetMidY(x))
#define kKWRandomHeading arc4random_uniform(kKWAngle360Degrees)
#define degreesToRadians(x) (M_PI * x / kKWAngle180Degrees)


#endif
