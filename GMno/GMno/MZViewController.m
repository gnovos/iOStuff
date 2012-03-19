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
#import <QuartzCore/QuartzCore.h>

@interface MZViewController ()

@end

@implementation MZViewController

@synthesize reader, type, code, name, description, verdict, torch;

- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image {
        
    NSLog(@"found %d symbols", [symbols count]);
    
    for (ZBarSymbol *sym in symbols) {
        NSLog(@"TYPE %@ CODE: %@ QUALITY: %d", sym.typeName, sym.data, sym.quality);
    }

    for (ZBarSymbol *sym in symbols) {  
        
        [reader stop];

        type.text = sym.typeName;
        code.text = @"";
        name.text = @"Looking up code...";
        description.text = @"";        
        verdict.text = @"PLEASE WAIT";
        
        NSString* data = sym.data;
        
        if ([data matches:kMZBarcodePattern]) {
            code.text = data;            
        }
        
        [MZBarcode lookup:sym.data withCompletion:^(MZBarcode *barcode) {     
            code.text = barcode.code;
            name.text = barcode.name;
            
            NSString* desc= [NSString stringWithFormat:@"Category: %@\nManufacturer: %@\n\n%@",
                             (barcode.category.length > 0 ? barcode.category : @"UNKNOWN"),
                             (barcode.company.length > 0 ? barcode.company : @"UNKNOWN"),
                             (barcode.description.length > 0 ? barcode.description : @"No Description")
                            ];
            
                        
            description.text = desc;
            
            verdict.text = barcode.source;

            if ([@"Conventional" isEqualToString:barcode.source]) {
                verdict.backgroundColor = [UIColor yellowColor];
            } else if ([@"Organic" isEqualToString:barcode.source]) {
                verdict.backgroundColor = [UIColor greenColor];
            } else if ([@"GMO" isEqualToString:barcode.source]) {
                verdict.backgroundColor = [UIColor redColor];                
            } else {
                verdict.backgroundColor = [UIColor lightGrayColor];                                
            }
            
            [reader start];
        }];
        
        break;                
    }
    
}

- (IBAction) toggleTorch:(id)sender {
    reader.torchMode = !reader.torchMode;
    [torch setSelected:reader.torchMode];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    reader.frame = CGRectMake(20.0f, 70.0f, 280.0f, 230.0f);
    
    reader.readerDelegate = self;  
    reader.torchMode = NO;
    
    [reader.scanner setSymbology:ZBAR_EAN2 config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_EAN5 config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_EAN8 config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_UPCE config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_ISBN10 config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_UPCA config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_EAN13 config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_ISBN13 config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_COMPOSITE config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_DATABAR config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_DATABAR_EXP config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_CODE39 config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_PDF417 config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_CODE93 config:ZBAR_CFG_ENABLE to:1];
    [reader.scanner setSymbology:ZBAR_CODE128 config:ZBAR_CFG_ENABLE to:1];
    
    //[reader.layer setCornerRadius:20.0f];
    [reader.layer setMasksToBounds:YES];   
        
    [verdict.layer setCornerRadius:8.0f];
    [verdict.layer setMasksToBounds:YES];    

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
