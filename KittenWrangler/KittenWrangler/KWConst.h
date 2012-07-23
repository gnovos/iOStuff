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
static const CGFloat kKWAngle15Degrees  = 15.0f;
static const CGFloat kKWAngle23Degrees  = 23.0f;
static const CGFloat kKWAngle45Degrees  = 45.0f;
static const CGFloat kKWAngle90Degrees  = 90.0f;
static const CGFloat kKWAngle180Degrees = 180.0f;
static const CGFloat kKWAngle270Degrees = 270.0f;
static const CGFloat kKWAngle360Degrees = 360.0f;

static const CGFloat kKWKittenInterest  = 0.5f;
static const CGFloat kKWKittensPerLevel = 3;

#define KWCGRectCenter(x) CGPointMake(CGRectGetMidX(x), CGRectGetMidY(x))
#define kKWRandom(amount) arc4random_uniform(amount)
#define kKWRandomHeading kKWRandom(kKWAngle360Degrees)
#define kKWRandomPercent (kKWRandom(100) / 100.0f)

#define degreesToRadians(deg) (deg * M_PI / kKWAngle180Degrees)
#define radiansToDegrees(rad) (rad * kKWAngle180Degrees / M_PI)

static const CGSize kKWDefaultKittenSize = { 35, 35 };
static const CGSize kKWDefaultBasketSize = { 70, 70 };
static const CGSize kKWDefaultMouseSize  = { 10, 10 };
static const CGSize kKWDefaultYarnSize   = { 50, 50 };


#endif
