//
//  LLMacro.h
//  CasuaLlama
//
//  Created by Mason on 9/3/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#ifndef CasuaLlama_LLMacro_h
#define CasuaLlama_LLMacro_h

#define LL_INIT_SINGELTON + (id) instance { \
    static id instance; \
    static dispatch_once_t once; \
    dispatch_once(&once, ^{ instance = [[self alloc] init]; }); \
    return instance; \
} 

#define LL_INIT_VIEW - (id) init { if (self = [super init]) { [self setup]; } return self; } \
- (id) initWithCoder:(NSCoder*)coder { if (self = [super initWithCoder:coder]) { [self setup]; } return self;} \
- (id) initWithFrame:(CGRect)frame { if (self = [super initWithFrame:frame]) { [self setup]; } return self; }

#define LL_INIT_VIEW_CONTROLLER - (void) didReceiveMemoryWarning { [super didReceiveMemoryWarning]; } \
- (id) initWithNibName:(NSString*)nib bundle:(NSBundle*)bundle { if (self = [super initWithNibName:nib bundle:bundle]) { [self setup]; } return self; } \
- (id) initWithCoder:(NSCoder*)decoder { if (self = [super initWithCoder:decoder]) { [self setup]; } return self; } \
- (id) init { if (self = [super init]) { [self setup]; } return self; }

#endif
