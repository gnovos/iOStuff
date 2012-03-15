//
//  MZUPCLookup.m
//  GMno
//
//  Created by Mason Glaves on 3/15/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MZUPCLookup.h"
#import "AFJSONRequestOperation.h"

@implementation MZUPCLookup

+ (NSURL*) APIURLForCode:(NSString*)code {
    NSString* url = [NSString stringWithFormat:@"%@/%@/%@", kMZAPIURL, kMZAPIKEY, code];
    return [NSURL URLWithString:url];
}

+ (void) lookup:(NSString*)code
{
    //{"valid":"true",
    //"number":"0111222333444",
    //"itemname":"UPC Database Testing Code",
    //"description":"http:\/\/www.upcdatabase.org\/code\/0111222333444",
    //"price":"123.45"}
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[self APIURLForCode:code]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, 
                                                                                                  NSHTTPURLResponse *response, 
                                                                                                  id JSON) 
    {
        NSLog(@"Found %@", JSON);
                                                                                            
        NSLog(@"Name: %@ %@", [JSON valueForKeyPath:@"valid"], [JSON valueForKeyPath:@"itemname"]);
    } failure:nil];
    
    [operation start];
    
}



@end
