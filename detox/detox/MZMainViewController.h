//
//  MZMainViewController.h
//  detox
//
//  Created by Mason Glaves on 4/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MZFlipsideViewController.h"

#import <CoreData/CoreData.h>

@interface MZMainViewController : UIViewController <MZFlipsideViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
