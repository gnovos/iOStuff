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
@property(nonatomic, strong) IBOutlet UILabel* item;
@property(nonatomic, strong) IBOutlet UILabel* verdict;



@end
