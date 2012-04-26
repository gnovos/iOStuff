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

int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSData* d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tt" ofType:@"json"]];
           
        JSONDecoder* decoder = [[JSONDecoder alloc] init];        
        NSDictionary* result;
        
        result = [MaSONKit parse:d]; 
        NSLog(@"%@\n", result);
        [MaSONKit freeRoot];
        
        sleep(100);
        
        if (1) return 0;
           
        uint64_t start = 0;
        uint64_t end = 0;
        uint64_t a = 0;
        uint64_t b = 0;
        
        uint64_t av = 0;
        uint64_t bv = 0;
        
        int awin = 0;
        int bwin = 0;
        
        for (int j=0;j<1000;j++) {
            
            if (j %2 ==0) {
                start = mach_absolute_time();            
                for (int i =0;i<1000;i++) { 
                    result = [MaSONKit parse:d]; 
                    //[MaSONKit freeRoot];
                }        
                end = mach_absolute_time();        
                a = end - start;        
                
                start = mach_absolute_time();            
                for (int i =0;i<1000;i++) {
                    result = [decoder objectWithData:d];
                }        
                end = mach_absolute_time();        
                b = end - start;      
                
            } else {
                
                start = mach_absolute_time();            
                for (int i =0;i<1000;i++) { 
                    result = [decoder objectWithData:d];
                }        
                end = mach_absolute_time();        
                b = end - start;      
                
                start = mach_absolute_time();            
                for (int i =0;i<1000;i++) { 
                    result = [MaSONKit parse:d]; 
                    //[MaSONKit freeRoot];
                }        
                end = mach_absolute_time();        
                a = end - start;        
                                
            }
            
            av += a / 1000;
            bv += b / 1000;

            long v1 = av / (j+1);
            long v2 = bv / (j+1);
            
            if (a < b) {
                awin++;
            } else {
                bwin++;
            }
            
            NSLog(@"\nAvB (%d/%d) a:%llu (%ld) b:%llu (%ld)", awin, bwin, a, v1, b, v2);                
            
        }
                
    }
    
}
