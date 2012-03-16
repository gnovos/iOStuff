//
//  MZUPCLookup.m
//  GMno
//
//  Created by Mason Glaves on 3/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MZBarcode.h"
#import "AFJSONRequestOperation.h"
#import "NSString+Match.h"

@implementation MZBarcode

@synthesize name, description, code, price, category;

+ (void) lookup:(NSString*)code withCompletion:(void(^)(MZBarcode* barcode))completion
{
    MZBarcode* barcode = [[MZBarcode alloc] init];

    barcode.code = code;
    barcode.category = @"Unknown";    
    
    if (![code matches:kMZBarcodePattern]) {
        barcode.code = nil;
        barcode.name = code;
        completion(barcode);
        return;        
    }    
    
    if ([code matches:kMZOrganicPLUPattern]) {
        barcode.category = @"Organic";           
    } else if ([code matches:kMZConventionalPLUPattern]) {
        barcode.category = @"Conventional";           
    } else if ([code matches:kMZGMOPLUPattern]) {
        barcode.category = @"GMO";                   
    }
    
    NSString* url = [NSString stringWithFormat:@"%@/%@/%@", kMZAPIURL, kMZAPIKEY, code];    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, 
                                                                                                  NSHTTPURLResponse *response,                                                                                                   id JSON) 
    {
        if ([[JSON valueForKey:@"valid"] boolValue]) {
            barcode.name = [JSON valueForKeyPath:@"itemname"];
            barcode.description = [JSON valueForKeyPath:@"description"];
            barcode.price = [JSON valueForKeyPath:@"price"];
        } else {
            barcode.name = @"Lookup Failed - Unknown Item";
        }
        
        completion(barcode);
                
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) 
    {        
        NSLog(@"Error was %@ JSON was %@", error, JSON);
                
    }];
    
    [operation start];
    
}



@end
