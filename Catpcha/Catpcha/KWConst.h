//
//  KWConst.h
//  Catpcha
//
//  Created by Mason on 7/17/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#ifndef Catpcha_KWConst_h
#define Catpcha_KWConst_h

static const CGFloat KWAngle0Degrees   = 0.0f;
static const CGFloat KWAngle15Degrees  = 15.0f;
static const CGFloat KWAngle23Degrees  = 23.0f;
static const CGFloat KWAngle45Degrees  = 45.0f;
static const CGFloat KWAngle90Degrees  = 90.0f;
static const CGFloat KWAngle180Degrees = 180.0f;
static const CGFloat KWAngle270Degrees = 270.0f;
static const CGFloat KWAngle360Degrees = 360.0f;

static const CGFloat KWKittensPerLevel = 2;

#define KWCGRectCenter(x) CGPointMake(CGRectGetMidX(x), CGRectGetMidY(x))
#define KWRandom(amount) arc4random_uniform(amount)
#define KWRandomHeading KWRandom(KWAngle360Degrees)
#define KWRandomPercent (KWRandom(1000000) / 1000000.0f)

#define KWMouseChance 0.001f

#define KWRandomSign ((KWRandom(2) % 2 == 0) ? 1 : -1)

#define degreesToRadians(deg) (deg * M_PI / KWAngle180Degrees)
#define radiansToDegrees(rad) (rad * KWAngle180Degrees / M_PI)

static const CGSize KWDefaultKittenSize = { 35, 35 };
static const CGSize KWDefaultBasketSize = { 70, 70 };
static const CGSize KWDefaultMouseSize  = { 10, 10 };
static const CGSize KWDefaultYarnSize   = { 50, 50 };

static const CGSize KWMinToySize        = { 10, 10 };


#define KWCheckpointLaunch @"[CHECKPOINT] Launch"


#endif
