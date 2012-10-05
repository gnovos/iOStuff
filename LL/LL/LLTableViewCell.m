//
//  LLTableViewCell.m
//  CasuaLlama
//
//  Created by Mason on 8/20/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "LLTableViewCell.h"

@interface LLTableViewCell ()
@end

@implementation LLTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuse {
    if (self = [super initWithStyle:style reuseIdentifier:reuse]) {}
    return self;
}

- (void) setValue:(id)value forUndefinedKey:(NSString*)key {
    vlog(@"KVC Undefined Key: %@", key);
}

- (void) setTitle:(NSString*)title { self.textLabel.text = title; }

- (void) setIcon:(NSString*)icon {
    UIImage* image = nil;
    if ([icon hasPrefix:@"http://"] || [icon hasPrefix:@"file://"]) {
        NSURL* url = [NSURL URLWithString:icon];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    }
    
    self.imageView.image = image;
}

@end
