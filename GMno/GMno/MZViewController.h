//
//  ZViewController.h
//  GMno
//
//  Created by Mason Glaves on 3/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZViewController : UIViewController<ZBarReaderViewDelegate>

@property(nonatomic, strong) IBOutlet ZBarReaderView* reader;

@property(nonatomic, strong) IBOutlet UILabel* type;
@property(nonatomic, strong) IBOutlet UILabel* code;
@property(nonatomic, strong) IBOutlet UILabel* name;
@property(nonatomic, strong) IBOutlet UITextView* description;
@property(nonatomic, strong) IBOutlet UILabel* verdict;

@property(nonatomic, strong) IBOutlet UIButton* torch;

- (IBAction) toggleTorch:(id)sender;

@end
