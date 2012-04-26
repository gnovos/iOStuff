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
           
        JSONDecoder* decoder = [[JSONDecoder alloc] init];        
        NSDictionary* result;
        
        result = [MaSONKit parse:d];
        
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
