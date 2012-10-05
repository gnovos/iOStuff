//
//  LLTableViewCell.h
//  CasuaLlama
//
//  Created by Mason on 8/20/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString* oid;

- (void) setValue:(id)value forUndefinedKey:(NSString*)key;

@end
