//
//  MZUPCLookup.m
//  GMno
//
//  Created by Mason Glaves on 3/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MZBarcode.h"
#import "AFJSONRequestOperation.h"

//http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=C4DA4948-1035-44DD-969C-8ED663623659&upc=upc_code 

#define kMZupcdatabaseAPIKEY @"82760dd501710ab053f6f3c519c10afb"
#define kMZupcdatabaseURL @"http://www.upcdatabase.org/api/json/%@/%@"

#define kMZeandataAPIKEY @"109C10104F629E59"
#define kMZeandataURL @"http://eandata.com/feed.php?mode=json&keycode=%@&find=%@"
#define kMZeandataDescriptionURL @"http://eandata.com/feed.php?mode=json&keycode=%@&find=%@&get=long_desc"


@implementation MZBarcode

@synthesize name, company, source, description, code, price, category;

- (id) initWithCode:(NSString*) initcode {
    if (self = [super init]) {
        code = initcode;
        name = @"Unknown Item";

        if (![code matches:kMZBarcodePattern]) {
            code = nil;
            name = initcode;
        } else if ([code matches:kMZOrganicPLUPattern]) {
            source = @"Organic";           
        } else if ([code matches:kMZConventionalPLUPattern]) {
            source = @"Conventional";           
        } else if ([code matches:kMZGMOPLUPattern]) {
            source = @"GMO";                   
        } else {
            source = @"Unknown";            
        }
        
    }
    return self;
}

+ (void) lookupFromUPCDatabase:(MZBarcode*)barcode withCompletion:(void(^)(MZBarcode* barcode))completion
{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:kMZupcdatabaseURL, kMZupcdatabaseAPIKEY, barcode.code]];
    
    [[AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:url]
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
      {
          if ([[JSON valueForKeyPath:@"valid"] boolValue]) {
              barcode.name = [JSON valueForKeyPath:@"itemname"];
              barcode.description = [JSON valueForKeyPath:@"description"];
              barcode.price = [JSON valueForKeyPath:@"price"];
          } else {
              barcode.name = @"Unknown Item";
              barcode.description = @"No description";              
          }
          
          completion(barcode);              
          
      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) { NSLog(@"Error was %@ JSON was %@", error, JSON); }
      ] start];
    
}

+ (void) lookupLongDescriptionFromEANData:(MZBarcode*)barcode withCompletion:(void(^)(MZBarcode* barcode))completion {
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:kMZeandataDescriptionURL, kMZeandataAPIKEY, barcode.code]];
    
    [[AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:url]
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
      {
          
          if ([[JSON valueForKeyPath:@"status.code"] intValue] == 200) {
              barcode.description = [JSON valueForKeyPath:@"product.long_desc"];
          } else {    
              barcode.description = @"No description";
          }
          completion(barcode);
                    
      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) { NSLog(@"Error was %@ JSON was %@", error, JSON);}
      ] start];
    
}

+ (void) lookupFromEANData:(MZBarcode*)barcode withCompletion:(void(^)(MZBarcode* barcode))completion {

    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:kMZeandataURL, kMZeandataAPIKEY, barcode.code]];
    
    [[AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:url]
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
      {          
          @try {
              if ([[JSON valueForKeyPath:@"status.code"] intValue] == 200) {
                  barcode.name = [JSON valueForKeyPath:@"product.product"];
                  
                  barcode.category = [JSON valueForKeyPath:@"product.category_text"];
                  barcode.company = [JSON valueForKeyPath:@"company.name"];
                  
                  if ([[JSON valueForKeyPath:@"product.has_long_desc"] boolValue]) {
                      [self lookupLongDescriptionFromEANData:barcode withCompletion:completion];
                  } else {
                      barcode.description = [JSON valueForKeyPath:@"product.description"];                  
                      completion(barcode);              
                  }              
              } else {
                  [self lookupFromUPCDatabase:barcode withCompletion:completion];                        
              }              
          }
          @catch (NSException * e) {
              NSLog(@"[EXCEPTION] %@\n[JSON] %@", e, JSON);
              [self lookupFromUPCDatabase:barcode withCompletion:completion];                        
          }          
          
      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) { NSLog(@"Error was %@ JSON was %@", error, JSON); }
    ] start];
    
}

+ (void) lookup:(NSString*)code withCompletion:(void(^)(MZBarcode* barcode))completion
{
    MZBarcode* barcode = [[MZBarcode alloc] initWithCode:code];
    if (barcode.code) {
        [self lookupFromEANData:barcode withCompletion:completion];
        //    [self lookupFromUPCDatabase:barcode withCompletion:completion];        
    } else {
        completion(barcode);
    }
    
}



@end
