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
           
        NSLog(@"d len is %d", [d length]);
        JSONDecoder* decoder = [[JSONDecoder alloc] init];        
        NSDictionary* result;
        
        result = [MaSONKit parse:d]; 
        NSLog(@"%d %@ %@", [result count], [result allKeys], result);
        [MaSONKit releaseRoot];
        
        uint64_t avg = 0;
        
        for (int j=0;j<1000;j++) {
            
            start = mach_absolute_time();            
            for (int i =0;i<1000;i++) { 
                result = [MaSONKit parse:d]; 
                [MaSONKit releaseRoot];
            }        
            end = mach_absolute_time();        
            melapsed = end - start;        
            
            start = mach_absolute_time();            
            for (int i =0;i<1000;i++) { 
                result = [decoder objectWithData:d]; 
            }
            end = mach_absolute_time();        
            jelapsed = end - start;        
                        
            avg += (uint64_t)(((jelapsed / (double)melapsed) * 100) - 100);
            NSLog(@"%llu:%llu %d%% faster (average %d%% faster)", melapsed, jelapsed, (int)((jelapsed / (double)melapsed) * 100) - 100, (int)(avg / (j+1)));
            
        }
                
    }
    
}
