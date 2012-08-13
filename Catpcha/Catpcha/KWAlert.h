//
//  KWAlert.h
//  Catpcha
//
//  Created by Mason on 8/1/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

@interface KWAlert : NSObject <UIAlertViewDelegate>

+ (void) alert:(NSString*)title message:(NSString*)message actions:(NSDictionary*)actions;

@end
