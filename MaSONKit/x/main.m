//
//  main.m
//  x
//
//  Created by Mason Glaves on 4/24/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MaSONKit.h"
#import "JSONKit.h"

#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>

static uint64_t start;
static uint64_t end;
static uint64_t melapsed;
static uint64_t jelapsed;

int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSData* d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"t" ofType:@"json"]];
//        NSString* s = @"{ \"firstName\": \"John\", \"last \\\\ \\\"my\\\" Name\" : \"Smith\", \"age\"      : 25, \"address\"  : { \"streetAddress\": \"21 2nd Street\", \"city\"         : \"New York\", \"states\"        : [ \"NY\", [\"CA\", 100]], \"postalCode\"   : \"10021\" },\"phoneNumber\":[{\"type\"  : \"home\", \"number\": \"212 555-1234\" }, { \"type\"  : \"fax\", \"number\": \"646 555-4567\"}]  \n}";
//        NSString* s = @"{ \"tx\" : [null, true, false], \"testnull\" : null, \"things\" : [ { \"a\" : \"b\" }, [ 5, 4, 3, 2, 1 ], \"thing1\", \"thing2\", 12345 ], \"name\": \"John\", \"age\" : 25, \"addresses\" : { \"mailing\" : { \"street\" : \"addy1\", \"post\" : 44321 }, \"shipping\" : { \"street\" : \"addy2\", \"post\" : 12345 } } }";
//        NSLog(@"%@", s);

        //NSLog(@"%@", [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding]);
                
//        NSData* d = [s dataUsingEncoding:NSUTF8StringEncoding];
           
        JSONDecoder* decoder = [[JSONDecoder alloc] init];        
        NSDictionary* result;
        
        for (int j=0;j<10;j++) {
            
            start = mach_absolute_time();            
            for (int i =0;i<10000;i++) { 
                result = [MaSONKit parse:d]; 
            }        
            end = mach_absolute_time();        
            melapsed = end - start;        
            NSLog(@"MK %d took %llu", j, melapsed);

            if (j == 0) { NSLog(@"MK result is %@", result);}
            
            start = mach_absolute_time();            
            for (int i =0;i<10000;i++) { 
                result = [decoder objectWithData:d]; 
            }
            end = mach_absolute_time();        
            jelapsed = end - start;        
            NSLog(@"JK %d took %llu", j, jelapsed);
            
//            NSLog(@"JK result is %@", result);
            
            NSLog(@"%d%% faster", (int)((jelapsed / (double)melapsed) * 100) - 100);
            
        }
                
    }
    
}
