//
//  ViewController.m
//  MParse
//
//  Created by Mason Glaves on 4/26/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "ViewController.h"
#import "MaSONKit.h"
#import <mach/mach.h>
#import <mach/mach_time.h>
#import <unistd.h>

#import "JSONKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self testParse:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)testParse:(id)sender
{
    JSONDecoder* d = [JSONDecoder decoder];    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"json"];
    NSData* data = [[NSData alloc] initWithContentsOfFile:path];
    
    NSLog(@"%@", [MaSONKit parse:data]);
            
    uint64_t start, end, elapsed = 0;
    int count = 10;
    
    for (int i =0;i<10;i++) {
        elapsed = 0;
        count += count * i;
        for (int i =0;i<count;i++) {
            start = mach_absolute_time();    
            [MaSONKit parse:data];
            end = mach_absolute_time();    
            elapsed += end - start;    
        }    
        NSLog(@"at %d MaSONKit took %llu", count, elapsed);
        
        elapsed = 0;
        for (int i =0;i<count;i++) {
            start = mach_absolute_time();    
            [d objectWithData:data];
            end = mach_absolute_time();    
            elapsed += end - start;    
        }    
        NSLog(@"at %d JSONKit  took %llu\n\n", count, elapsed);
        
    }
    

}

@end






