//
//  MZUPCLookup.m
//  GMno
//
//  Created by Mason Glaves on 3/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MZBarcode.h"
#import "AFJSONRequestOperation.h"

@implementation MZBarcode

@synthesize name, description, code, price;

+ (void) lookup:(NSString*)code withCompletion:(void(^)(MZBarcode* code))completion
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [code rangeOfCharacterFromSet: nonNumbers];
    if (r.location != NSNotFound) {
        MZBarcode* barcode = [[MZBarcode alloc] init];
        barcode.name = code;
        completion(barcode);
        return;
    }
        
    NSString* url = [NSString stringWithFormat:@"%@/%@/%@", kMZAPIURL, kMZAPIKEY, code];    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, 
                                                                                                  NSHTTPURLResponse *response,                                                                                                   id JSON) 
    {
        MZBarcode* barcode = [[MZBarcode alloc] init];
        barcode.code = code;
        
        if ([[JSON valueForKey:@"valid"] boolValue]) {
            barcode.name = [JSON valueForKeyPath:@"itemname"];
            barcode.description = [JSON valueForKeyPath:@"description"];
            barcode.price = [JSON valueForKeyPath:@"price"];
        } else {
            barcode.name = @"Unknown Item";
        }
        
        completion(barcode);
                
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) 
    {
        
        NSLog(@"Error was %@ JSON was %@", error, JSON);
                
    }];
    
    [operation start];
    
}



@end
