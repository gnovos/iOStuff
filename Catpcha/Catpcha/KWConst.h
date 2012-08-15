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
#define KWRandomDegrees KWRandom(KWAngle360Degrees)
#define KWRandomPercent (KWRandom(1000000) / 1000000.0f)
#define KWRandomSign ((KWRandom(2) % 2 == 0) ? 1 : -1)

#define KWRandomf(f) arc4random_uniform(f * 1000000.0f) / 1000000.0f

#define KWRandomRange(low, high) (arc4random_uniform((high - low) * 1000000.0f) / 1000000.0f) - ((high - low) / 2.0f)
#define KWRandomPoint(rect) GLKVector2Make(KWRandomRange(rect.origin.x, rect.size.width + rect.origin.x), KWRandomRange(rect.origin.y, rect.size.height + rect.origin.y))
#define KWRandomPosition(size, bounds) KWRandomPoint(CGRectInset(bounds, size.width / 2.0f, size.height / 2.0f));

#define KWMouseChance 0.001f

#define degreesToRadians(deg) (deg * M_PI / KWAngle180Degrees)
#define radiansToDegrees(rad) (rad * KWAngle180Degrees / M_PI)

static const CGSize KWBasketSize = { 0.2f,  0.2f  };
static const CGSize KWKittenSize = { 0.1f,  0.1f  };
static const CGSize KWMouseSize  = { 0.05f, 0.05f };
static const CGSize KWYarnSize   = { 0.08f, 0.08f };

static const CGSize KWMinToySize = { 0.05f, 0.05f };

static const GLKVector4 clear    = { 0.0f, 0.0f, 0.0f, 0.0f };
static const GLKVector4 white    = { 1.0f, 1.0f, 1.0f, 1.0f };
static const GLKVector4 black    = { 0.0f, 0.0f, 0.0f, 1.0f };
static const GLKVector4 red      = { 1.0f, 0.0f, 0.0f, 1.0f };
static const GLKVector4 green    = { 0.0f, 1.0f, 0.0f, 1.0f };
static const GLKVector4 blue     = { 0.0f, 0.0f, 1.0f, 1.0f };

static const GLKVector4 pink      = { 0.9f, 0.5f, 0.7f, 0.7f };
static const GLKVector4 palegreen = { 0.5f, 0.9f, 0.4f, 0.7f };
static const GLKVector4 paleblue  = { 0.5f, 0.4f, 0.9f, 0.7f };
static const GLKVector4 palered   = { 0.9f, 0.2f, 0.1f, 0.7f };

#define M_TAU ( 2 * M_PI)

#define KWNoticePadding 10.0f
#define KWNoticeFontSize 12.0f

#define KWFlashDuration 1.0f
#define KWHoverDuration 3.5f

#define KWTouchFeather -10.0f

#define KWCheckpointLaunch @"[CHECKPOINT] Launch"


#endif
