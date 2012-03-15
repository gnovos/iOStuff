//
//  ZViewController.m
//  GMno
//
//  Created by Mason Glaves on 3/13/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

//AVCaptureVideoPreviewLayer

#import "MZViewController.h"
#import "MZBarcode.h"

@interface MZViewController ()

@end

@implementation MZViewController

@synthesize reader, type, code, name, description, verdict;

- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image {
    
    NSLog(@"found %d symbols", [symbols count]);
    
    for (ZBarSymbol *sym in symbols) {
        NSLog(@"TYPE %@ CODE: %@ | %d : %d", sym.typeName, sym.data, sym.quality, sym.count);
        break;                
    }

    for (ZBarSymbol *sym in symbols) {  
        type.text = nil;
        code.text = nil;
        name.text = @"Looking up code...";
        description.text = nil;        
        verdict.text = @"PLEASE WAIT";
        
        [MZBarcode lookup:sym.data withCompletion:^(MZBarcode *barcode) {            
            type.text = sym.typeName;
            code.text = sym.data;
            name.text = barcode.name;
            description.text = barcode.description;
            verdict.text = @"FOUND";
        }];
        
        break;                
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
