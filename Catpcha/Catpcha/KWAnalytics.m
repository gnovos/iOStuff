//
//  KWAnalytics.m
//  Catpcha
//
//  Created by Mason on 11/19/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "KWAnalytics.h"
#import "TestFlight.h"
#import "Flurry.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "SSKeychain.h"

@implementation KWAnalytics

#define KWFlurryAPIKey @"KGPXKF962BYXMPMWPSYC"
#define KWTestFlightAPIKey @"4458812bd5ebcfc812a03b2015057c83_MTAzMTA2MjAxMi0wNi0yMyAwMTo1Nzo0OS40NzgyMDg"

#define KWUDIDService @"org.casuallama.UDID.v1"
#define KWUDIDAccount @"catpcha"

+ (NSString*) deviceID {
    
    static NSString* udid;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        udid = [SSKeychain passwordForService:KWUDIDService account:KWUDIDAccount];
        if (udid == nil) {
            NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
            NSString* app = [info objectForKey:@"CFBundleDisplayName"];
            NSString* version = [info objectForKey:@"CFBundleShortVersionString"];
            NSString* build = [info objectForKey:@"CFBundleVersion"];
            
            NSString* xudid = [NSString stringWithFormat:@"[%@] %@/(%@) %@", app, version, build, [self mac]];
            [SSKeychain setPassword:xudid forService:KWUDIDService account:KWUDIDAccount];
        }
        
    });
    return udid;
    
}

+ (NSString*) mac {
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        dlog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

+ (void) checkpoint:(NSString*)checkpoint {
    @try {
        [TestFlight passCheckpoint:checkpoint];
    }
    @catch (id exception) {
        elog(exception);
    }
}


+ (void) init {
    @try {
        [TestFlight takeOff:KWTestFlightAPIKey];
        [TestFlight setDeviceIdentifier:[self deviceID]];
    }
    @catch (id exception) {
        elog(exception);
    }
    
    @try {
        [Flurry setShowErrorInLogEnabled:YES];
        [Flurry setDebugLogEnabled:YES];
        [Flurry startSession:KWFlurryAPIKey];
        
        [Flurry setSessionReportsOnPauseEnabled:YES];
        [Flurry setUserID:[self deviceID]];
    }
    @catch (id exception) {
        elog(exception);
    }
    
    @try {
        [self checkpoint:KWCheckpointLaunch];
    }
    @catch (id exception) {
        elog(exception);
    }
}

+ (void) flurryLocation {
//    CLLocationManager *lman = [[CLLocationManager alloc] init];
//    [lman startUpdatingLocation];
//
//    CLLocation *loc = lman.location;
//    [Flurry setLatitude:loc.coordinate.latitude
//              longitude:loc.coordinate.longitude
//     horizontalAccuracy:loc.horizontalAccuracy
//       verticalAccuracy:loc.verticalAccuracy];
}

+ (void) flurry:(NSString*)name event:(id)event {
    [self flurry:name event:event block:nil];
}

+ (void) flurry:(NSString*)name event:(id)event block:(NSDictionary* (^)(void))block {
    if ([event isKindOfClass:[NSError class]]) {
        [Flurry logError:name message:[event description] error:event];
    } else if ([event isKindOfClass:[NSException class]]) {
        [Flurry logError:name message:[event description] exception:event];
    } else {
        BOOL timed = block != nil;
        [Flurry logEvent:name withParameters:event timed:timed];
        if (timed) {
            [Flurry endTimedEvent:name withParameters:block()];
        }
    }    
}

+ (void) launchFeedback { [TestFlight openFeedbackView]; }


@end
