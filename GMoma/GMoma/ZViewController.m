//
//  ZViewController.m
//  GMoma
//
//  Created by Mason Glaves on 3/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

//AVCaptureVideoPreviewLayer

#import "ZViewController.h"

@interface ZViewController ()

@end

@implementation ZViewController

@synthesize reader, code, type, item, verdict;

- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image {
    
    for(ZBarSymbol *sym in symbols) {
        NSLog(@"%@ data was %@", sym.typeName, sym.data);
        type.text = [NSString stringWithFormat:@"FOUND %@", sym.typeName];
        code.text = sym.data;
        verdict.text = @"UNKNOWN";
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    reader.frame = CGRectMake(20.0f, 20.0f, 280.0f, 230.0f);
    
    [reader setClipsToBounds:YES];
    
    reader.readerDelegate = self;  
    reader.torchMode = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    [reader start];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [reader stop];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
