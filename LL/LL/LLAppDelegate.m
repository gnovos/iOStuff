//
//  LLAppDelegate.m
//  CasuaLlama
//
//  Created by Mason on 8/18/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "LLAppDelegate.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "NSObject+LL.h"

/*
 data = {
 
 "text"    : { "text" : "url to file or text" },
 "image"   : { "path" : "url or bundle name" },
 "web"     : { "path" : "url or inline" },
 "pdf"     : { "path" : "url or bundle name", "page" : "page number or missing" },
 "map"     : { },
 
 "table"   : { "view"     : "name or default (or missing)",
 "sections" : [{ "title" : "string or null/false (or missing)", "rows"  : [objs]}]},
 
 "book"    : { "view" : "name or default (or missing)", "pages" : [objs] },
 "gallery" : { "view" : "name or default (or missing)", "items" : [objs] }
 
 }
 */

@implementation LLAppDelegate

+ (id) instance { return [[UIApplication sharedApplication] delegate]; }

- (NSString*) deviceID {
    
    static NSString* udid;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        //xxx first check keychain
        NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
        NSString* app = [info objectForKey:@"CFBundleDisplayName"];
        NSString* version = [info objectForKey:@"CFBundleShortVersionString"];
        NSString* build = [info objectForKey:@"CFBundleVersion"];
        NSString* uniq = [[NSProcessInfo processInfo] globallyUniqueString];
        
        udid = [NSString stringWithFormat:@"[%@] %@/(%@) %@ %@", app, version, build, [self mac], uniq];
        //xxx store in keychain
    });
    return udid;
    
}

- (NSString*) mac {
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
    if (errorFlag != NULL) {
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


- (BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    
    NSDictionary* d = @{
      @"foo" : @"bar",
      @"alpha" : @{ @"a" : @"b", @"arr" : @[ @10, @15, @20 ] },
      @"numer" : @{ @"1" : @"2" },
      @"exp"   : @{ @"e1" : @"#{foo}", @"e2" : @"#{numer.1}", @"e3" : @"#{alpha.arr[2]}" },
    };
    
    NSMutableDictionary* op = [NSMutableDictionary dictionary];
    
    [d walk:^(NSString* key, id value) {
        NSLog(@"\nkey:   %@\nvalue: %@\n\n", key, value);
        [op setValue:value forPath:key];
    }];
    
    NSLog(@"\nd was %@\n\nop is %@\n\n", d, op);
    
    [op setValue:[@{ @"a" : @"b" } mutableCopy] forPath:@"fooz.bar"];
    
    NSLog(@"\nd was%@\n\n", op);
    
    [op setValue:@"xxxx" forPath:@"fooz.bar.c"];
    
    NSLog(@"\nd was%@\n\n", op);
    
    [op setValue:@"#{fooz.bar.c}" forPath:@"yyyy"];
    
    NSLog(@"\nd was%@\n\n", op);

    
    sleep(100);
    abort();
    
    [TestFlight takeOff:@"4458812bd5ebcfc812a03b2015057c83_MTAzMTA2MjAxMi0wNi0yMyAwMTo1Nzo0OS40NzgyMDg"];
    
    _settings = [NSUserDefaults standardUserDefaults];
    [_settings synchronize];
    
    UIRemoteNotificationType types = (UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeNewsstandContentAvailability);
    [self.application registerForRemoteNotificationTypes:types];
    
        
    UILocalNotification* note = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (note) { [self handle:[note.alertAction lowercaseString] info:note.userInfo]; }
    
    //self.nav.delegate = self;
        
    return YES && [self checkpoint:@"launch complete"];
}

- (UIStoryboard*) storyboard { return self.root.storyboard; }
- (UIViewController*) root { return self.window.rootViewController; }
- (UINavigationController*) nav { return (UINavigationController*)self.root; }

- (UIApplication*) application { return [UIApplication sharedApplication]; }
- (NSURL*) documents { return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]; }
- (void) raise:(NSError*)error { [[NSException exceptionWithName:@"LLFatalException" reason:[error localizedDescription] userInfo:[error userInfo]] raise]; }

- (void) alert:(NSString*)action message:(NSString*)message {
    NSString* name = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleExecutableKey];
    [[[UIAlertView alloc] initWithTitle:name
                                message:message
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:action, nil] show];
}

- (void) application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)note {
    if ([application applicationState] == UIApplicationStateActive) {
        [self alert:note.alertAction message:note.alertBody];
    } else {
        [self handle:[note.alertAction lowercaseString] info:note.userInfo];
    }
}

- (void)applicationWillEnterForeground:(UIApplication*)application { }
- (void)applicationDidBecomeActive:(UIApplication*)application     { }
- (void)applicationWillResignActive:(UIApplication*)application    { }
- (void)applicationDidEnterBackground:(UIApplication*)application  { }
- (void)applicationWillTerminate:(UIApplication*)application       { }

- (void)alertView:(UIAlertView*)alert clickedButtonAtIndex:(NSInteger)index {
    if (index != alert.cancelButtonIndex) { [self handle:[[alert buttonTitleAtIndex:index] lowercaseString] info:nil]; }
}

- (void) handle:(NSString*)action info:(NSDictionary*)info {
    if ([@"call" isEqualToString:action]) {
        [self open:[NSURL URLWithString:[@"tel:" stringByAppendingString:[info objectForKey:@"number"]]]];
    } else if ([@"open" isEqualToString:action]) {
        [self open:[info objectForKey:@"url"]];
    }
}

- (void) open:(NSURL*)url {
    [self.application openURL:url];
}

- (void) notify {
    [self.application cancelAllLocalNotifications];
}

- (void) navigationController:(UINavigationController*)nav willShowViewController:(UIViewController*)vc animated:(BOOL)animated {
    BOOL root = [nav.viewControllers objectAtIndex:0] == vc;
    [nav setNavigationBarHidden:root animated:animated];
}

- (void) navigationController:(UINavigationController*)nav didShowViewController:(UIViewController*)vc animated:(BOOL)animated {
    BOOL root = [nav.viewControllers objectAtIndex:0] == vc;
    [nav setNavigationBarHidden:root animated:animated];
}

- (BOOL) checkpoint:(NSString*)checkpoint {
    [TestFlight passCheckpoint:checkpoint];
    return YES;
}



@end
