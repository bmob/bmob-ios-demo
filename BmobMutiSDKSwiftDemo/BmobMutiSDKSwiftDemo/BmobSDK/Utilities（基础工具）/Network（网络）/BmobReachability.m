/*
 
 File: Reachability.m
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 
 Version: 2.0.4ddg
 */

/*
 Significant additions made by Andrew W. Donoho, August 11, 2009.
 This is a derived work of Apple's Reachability v2.0 class.
 
 The below license is the new BSD license with the OSI recommended personalizations.
 <http://www.opensource.org/licenses/bsd-license.php>

 Extensions Copyright (C) 2009 Donoho Design Group, LLC. All Rights Reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Andrew W. Donoho nor Donoho Design Group, L.L.C.
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY DONOHO DESIGN GROUP, L.L.C. "AS IS" AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */


/*
 
 Apple's Original License on Reachability v2.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.

 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
*/

/*
 Each reachability object now has a copy of the key used to store it in a dictionary.
 This allows each observer to quickly determine if the event is important to them.
*/

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

//#import <CoreFoundation/CoreFoundation.h>

#import "BmobReachability.h"

//NSString *const bmobkInternetConnection  = @"InternetConnection";
//NSString *const bmobkLocalWiFiConnection = @"LocalWiFiConnection";
NSString *const bmobkReachabilityChangedNotification = @"NetworkReachabilityChangedNotification";

//#define CLASS_DEBUG 1 // Turn on logReachabilityFlags. Must also have a project wide defined DEBUG.
//
//#if (defined DEBUG && defined CLASS_DEBUG)
//#define logReachabilityFlags(flags) (logReachabilityFlags_(__PRETTY_FUNCTION__, __LINE__, flags))
//
//static NSString *reachabilityFlags_(SCNetworkReachabilityFlags flags) {
//
//#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 30000) // Apple advises you to use the magic number instead of a symbol.
//    return [NSString stringWithFormat:@"Reachability Flags: %c%c %c%c%c%c%c%c%c",
//            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
//            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
//
//            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
//            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
//            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
//            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
//            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
//            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
//            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
//#else
//    // Compile out the v3.0 features for v2.2.1 deployment.
//    return [NSString stringWithFormat:@"Reachability Flags: %c%c %c%c%c%c%c%c",
//            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
//            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
//
//            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
//            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
//            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
//            // v3 kSCNetworkReachabilityFlagsConnectionOnTraffic == v2 kSCNetworkReachabilityFlagsConnectionAutomatic
//            (flags & kSCNetworkReachabilityFlagsConnectionAutomatic)  ? 'C' : '-',
//            // (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-', // No v2 equivalent.
//            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
//            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
//#endif
//
//} // reachabilityFlags_()
//
//static void logReachabilityFlags_(const char *name, int line, SCNetworkReachabilityFlags flags) {
//
//    NSLog(@"%s (%d) \n\t%@", name, line, reachabilityFlags_(flags));
//
//} // logReachabilityFlags_()
//
//#define logNetworkStatus(status) (logNetworkStatus_(__PRETTY_FUNCTION__, __LINE__, status))
//
////static void logNetworkStatus_(const char *name, int line, NetworkStatus status) {
////
////    NSString *statusString = nil;
////
////    switch (status) {
////        case kNotReachable:
////            statusString = @"Not Reachable";
////            break;
////        case kReachableViaWWAN:
////            statusString = @"Reachable via WWAN";
////            break;
////        case kReachableViaWiFi:
////            statusString = @"Reachable via WiFi";
////            break;
////    }
////
////    NSLog(@"%s (%d) \n\tNetwork Status: %@", name, line, statusString);
////
////} // logNetworkStatus_()
//
//#else
//#define logReachabilityFlags(flags)
//#define logNetworkStatus(status)
//#endif

@interface BmobReachability ()

//- (NetworkStatus) networkStatusForFlags: (SCNetworkReachabilityFlags) flags;
//1208
@property (nonatomic, assign) SCNetworkReachabilityRef  reachabilityRef;
@property (nonatomic, strong) dispatch_queue_t          reachabilitySerialQueue;
@property (nonatomic, strong) id                        reachabilityObject;

-(void)reachabilityChanged:(SCNetworkReachabilityFlags)flags;
-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags;
@end

static NSString *reachabilityFlags(SCNetworkReachabilityFlags flags)
{
    return [NSString stringWithFormat:@"%c%c %c%c%c%c%c%c%c",
#if    TARGET_OS_IPHONE
            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
#else
            'X',
#endif
            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
}

// Start listening for reachability notifications on the current run loop
static void TMReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target)
    
    BmobReachability *reachability = ((__bridge BmobReachability *)info);
    
    // We probably don't need an autoreleasepool here, as GCD docs state each queue has its own autorelease pool,
    // but what the heck eh?
    @autoreleasepool
    {
        [reachability reachabilityChanged:flags];
    }
}


@implementation BmobReachability

+(BmobReachability *)reachabilityWithHostName:(NSString*)hostname
{
    return [BmobReachability reachabilityWithHostname:hostname];
}

+ (BmobReachability *) reachabilityWithHostname: (NSString *) hostName {
    
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    
    if (ref) {
        
        BmobReachability *r = [[[self alloc] initWithReachabilityRef: ref] autorelease];
        
       // r.key = hostName;
        
        return r;
        
    }
    
    return nil;
    
} // reachabilityWithHostName

+ (BmobReachability *) reachabilityWithAddress: (const struct sockaddr_in *) hostAddress {
    
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    
    if (ref) {
        
        BmobReachability *r = [[[self alloc] initWithReachabilityRef: ref] autorelease];
        
        //r.key = [self makeAddressKey: hostAddress->sin_addr.s_addr];
        
        return r;
        
    }
    
    return nil;
    
} // reachabilityWithAddress

+ (BmobReachability *) reachabilityForInternetConnection {
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    BmobReachability *r = [self reachabilityWithAddress: &zeroAddress];
    
   // r.key = bmobkInternetConnection;
    
    return r;
    
} // reachabilityForInternetConnection

+ (BmobReachability *) reachabilityForLocalWiFi {
    
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    
    BmobReachability *r = [self reachabilityWithAddress: &localWifiAddress];
    
    //r.key = bmobkLocalWiFiConnection;
    
    return r;
    
} // reachabilityForLocalWiFi

- (BmobReachability *) initWithReachabilityRef: (SCNetworkReachabilityRef) ref
{
    self = [super init];
    if (self != nil)
    {
        //    reachabilityRef = ref;
        self.reachableOnWWAN = YES;
        self.reachabilityRef = ref;
        
        // We need to create a serial queue.
        // We allocate this once for the lifetime of the notifier.
        
        self.reachabilitySerialQueue = dispatch_queue_create("com.tonymillion.reachability", NULL);
    }
    
    return self;
    
} // initWithReachabilityRef:

- (void) dealloc {
    
    [self stopNotifier];
    if(self.reachabilityRef) {
        //CFRelease(reachabilityRef); reachabilityRef = NULL;
        CFRelease(self.reachabilityRef);
        self.reachabilityRef = nil;
        
    }
    
    //self.key = nil;
    self.reachableBlock          = nil;
    self.unreachableBlock        = nil;
    self.reachabilityBlock       = nil;
    self.reachabilitySerialQueue = nil;
    
    [super dealloc];
    
} // dealloc

#pragma mark - Notifier Methods
- (BOOL) startNotifier {
    if(self.reachabilityObject && (self.reachabilityObject == self))
    {
        return YES;
    }

    SCNetworkReachabilityContext    context = {0, NULL, NULL, NULL, NULL};
    context.info = (__bridge void *)self;
    if(SCNetworkReachabilitySetCallback(self.reachabilityRef, TMReachabilityCallback, &context)) {
        
        //        if(SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
        //
        //            return YES;
        //
        //        }
        // Set it as our reachability queue, which will retain the queue
        if(SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue))
        {
            // this should do a retain on ourself, so as long as we're in notifier mode we shouldn't disappear out from under ourselves
            // woah
            self.reachabilityObject = self;
            return YES;
        }
        else
        {
#ifdef DEBUG
            NSLog(@"SCNetworkReachabilitySetDispatchQueue() failed: %s", SCErrorString(SCError()));
#endif
            
            // UH OH - FAILURE - stop any callbacks!
            SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
        }
    }
    else
    {
#ifdef DEBUG
        NSLog(@"SCNetworkReachabilitySetCallback() failed: %s", SCErrorString(SCError()));
#endif
    }
    
    // if we get here we fail at the internet
    self.reachabilityObject = nil;
    return NO;
    
    //    }
    
    //    return NO;
    
} // startNotifier


- (void) stopNotifier {
    
    //    if(reachabilityRef) {
    //
    //        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    //
    //    }
    // First stop, any callbacks!
    SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
    
    // Unregister target from the GCD serial dispatch queue.
    SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, NULL);
    
    self.reachabilityObject = nil;
    
} // stopNotifier
//@synthesize key = key_;

#define testcase (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)

-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags
{
    BOOL connectionUP = YES;
    
    if(!(flags & kSCNetworkReachabilityFlagsReachable))
        connectionUP = NO;
    
    if( (flags & testcase) == testcase )
        connectionUP = NO;
    
#if    TARGET_OS_IPHONE
    if(flags & kSCNetworkReachabilityFlagsIsWWAN)
    {
        // We're on 3G.
        if(!self.reachableOnWWAN)
        {
            // We don't want to connect when on 3G.
            connectionUP = NO;
        }
    }
#endif
    
    return connectionUP;
}

- (BOOL) isReachable {
    
    //    NSAssert(reachabilityRef, @"isReachable called with NULL reachabilityRef");
    //
    //    SCNetworkReachabilityFlags flags = 0;
    //    NetworkStatus status = kNotReachable;
    //
    //    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
    //
    ////        logReachabilityFlags(flags);
    //
    //        status = [self networkStatusForFlags: flags];
    //
    ////        logNetworkStatus(status);
    //
    //        return (kNotReachable != status);
    //
    //    }
    //
    //    return NO;
    
    SCNetworkReachabilityFlags flags;
    
    if(!SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
        return NO;
    
    return [self isReachableWithFlags:flags];
    
} // isReachable

- (BOOL) isReachableViaWWAN {
    //
    //    NSAssert(reachabilityRef, @"isReachableViaWWAN called with NULL reachabilityRef");
    //
    //    SCNetworkReachabilityFlags flags = 0;
    //    NetworkStatus status = kNotReachable;
    //
    //    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
    //
    //        logReachabilityFlags(flags);
    //
    //        status = [self networkStatusForFlags: flags];
    //
    //        return  (kReachableViaWWAN == status);
    //
    //    }
    //
    //    return NO;
    
#if    TARGET_OS_IPHONE
    
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        // Check we're REACHABLE
        if(flags & kSCNetworkReachabilityFlagsReachable)
        {
            // Now, check we're on WWAN
            if(flags & kSCNetworkReachabilityFlagsIsWWAN)
            {
                return YES;
            }
        }
    }
#endif
    
    return NO;
    
} // isReachableViaWWAN

- (BOOL) isReachableViaWiFi {
    
    //    NSAssert(reachabilityRef, @"isReachableViaWiFi called with NULL reachabilityRef");
    //
    //    SCNetworkReachabilityFlags flags = 0;
    //    NetworkStatus status = kNotReachable;
    //
    //    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
    //
    //        logReachabilityFlags(flags);
    //
    //        status = [self networkStatusForFlags: flags];
    //
    //        return  (kReachableViaWiFi == status);
    //
    //    }
    //
    //    return NO;
    
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        // Check we're reachable
        if((flags & kSCNetworkReachabilityFlagsReachable))
        {
#if    TARGET_OS_IPHONE
            // Check we're NOT on WWAN
            if((flags & kSCNetworkReachabilityFlagsIsWWAN))
            {
                return NO;
            }
#endif
            return YES;
        }
    }
    
    return NO;
    
} // isReachableViaWiFi


- (BOOL) isConnectionRequired {
    
    //    NSAssert(reachabilityRef, @"isConnectionRequired called with NULL reachabilityRef");
    //
    //    SCNetworkReachabilityFlags flags;
    //
    //    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
    //
    //        logReachabilityFlags(flags);
    //
    //        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    //
    //    }
    //
    //    return NO;
    return [self connectionRequired];
    
} // isConnectionRequired

-(BOOL)connectionRequired
{
    SCNetworkReachabilityFlags flags;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}

- (BOOL) isConnectionOnDemand {
    
    //    NSAssert(reachabilityRef, @"isConnectionIsOnDemand called with NULL reachabilityRef");
    //
    //    SCNetworkReachabilityFlags flags;
    //
    //    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
    //
    //        logReachabilityFlags(flags);
    //
    //        return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
    //                (flags & kOnDemandConnection));
    //
    //    }
    //
    //    return NO;
    
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
                (flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand)));
    }
    
    return NO;
    
} // isConnectionOnDemand

- (BOOL) isInterventionRequired {
    
    //    NSAssert(reachabilityRef, @"isInterventionRequired called with NULL reachabilityRef");
    //
    //    SCNetworkReachabilityFlags flags;
    //
    //    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
    //
    //        logReachabilityFlags(flags);
    //
    //        return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
    //                (flags & kSCNetworkReachabilityFlagsInterventionRequired));
    //
    //    }
    //
    //    return NO;
    
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
                (flags & kSCNetworkReachabilityFlagsInterventionRequired));
    }
    
    return NO;
    
} // isInterventionRequired

- (NetworkStatus) currentReachabilityStatus
{
    //    NSAssert(reachabilityRef, @"currentReachabilityStatus called with NULL reachabilityRef");
    //
    //    NetworkStatus retVal = NotReachable;
    //    SCNetworkReachabilityFlags flags;
    //    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    //    {
    //        if(self.key == kLocalWiFiConnection)
    //        {
    //            retVal = [self localWiFiStatusForFlags: flags];
    //        }
    //        else
    //        {
    //            retVal = [self networkStatusForFlags: flags];
    //        }
    //    }
    //    return retVal;
    
    if([self isReachable])
    {
        if([self isReachableViaWiFi])
            return ReachableViaWiFi;
        
#if    TARGET_OS_IPHONE
        return ReachableViaWWAN;
#endif
    }
    
    return NotReachable;
}
//- (NetworkStatus) currentReachabilityStatus {
//
//    NSAssert(reachabilityRef, @"currentReachabilityStatus called with NULL reachabilityRef");
//
//    SCNetworkReachabilityFlags flags = 0;
//    NetworkStatus status = kNotReachable;
//
//    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
//
////        logReachabilityFlags(flags);
//
//        status = [self networkStatusForFlags: flags];
//
//        return status;
//
//    }
//
//    return kNotReachable;
//
//} // currentReachabilityStatus

- (SCNetworkReachabilityFlags) reachabilityFlags {
    
    //    NSAssert(reachabilityRef, @"reachabilityFlags called with NULL reachabilityRef");
    //
    //    SCNetworkReachabilityFlags flags = 0;
    //
    //    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
    //
    //        logReachabilityFlags(flags);
    //
    //        return flags;
    //
    //    }
    //
    //    return 0;
    
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        return flags;
    }
    
    return 0;
    
} // reachabilityFlags

-(NSString*)currentReachabilityString
{
    NetworkStatus temp = [self currentReachabilityStatus];
    
    if(temp == ReachableViaWWAN)
    {
        // Updated for the fact that we have CDMA phones now!
        return NSLocalizedString(@"Cellular", @"");
    }
    if (temp == ReachableViaWiFi)
    {
        return NSLocalizedString(@"WiFi", @"");
    }
    
    return NSLocalizedString(@"No Connection", @"");
}

-(NSString*)currentReachabilityFlags
{
    return reachabilityFlags([self reachabilityFlags]);
}

#pragma mark - Callback function calls this method

-(void)reachabilityChanged:(SCNetworkReachabilityFlags)flags
{
    if([self isReachableWithFlags:flags])
    {
        if(self.reachableBlock)
        {
            self.reachableBlock(self);
        }
    }
    else
    {
        if(self.unreachableBlock)
        {
            self.unreachableBlock(self);
        }
    }
    
    if(self.reachabilityBlock)
    {
        self.reachabilityBlock(self, flags);
    }
    
    // this makes sure the change notification happens on the MAIN THREAD
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:bmobkReachabilityChangedNotification
                                                            object:self];
    });
}

#pragma mark - Callback function calls this method
//#if (defined DEBUG && defined CLASS_DEBUG)
- (NSString *) description {
    
    //    NSAssert(reachabilityRef, @"-description called with NULL reachabilityRef");
    //
    //    SCNetworkReachabilityFlags flags = 0;
    //
    //    SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
    //
    //    return [NSString stringWithFormat: @"%@\n\t%@", self.key, reachabilityFlags_(flags)];
    
    NSString *description = [NSString stringWithFormat:@"<%@: %#tx (%@)>",
                                 NSStringFromClass([self class]), (uintptr_t)self, [self currentReachabilityFlags]];
    return description;
    
} // description
//#endif





//// Preclude direct access to ivars.
//+ (BOOL) accessInstanceVariablesDirectly {
//
//    return NO;
//
//} // accessInstanceVariablesDirectly
//
//
//
//
//#pragma mark -
//#pragma mark Notification Management Methods
//
//
////Start listening for reachability notifications on the current run loop
//static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
//
//#pragma unused (target, flags)
//    NSCAssert(info, @"info was NULL in ReachabilityCallback");
//    NSCAssert([(NSObject*) info isKindOfClass: [BmobReachability class]], @"info was the wrong class in ReachabilityCallback");
//
//    //We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
//    // in case someone uses the Reachablity object in a different thread.
//    NSAutoreleasePool* pool = [NSAutoreleasePool new];
//
//    // Post a notification to notify the client that the network reachability changed.
//    [[NSNotificationCenter defaultCenter] postNotificationName: bmobkReachabilityChangedNotification
//                                                        object: (BmobReachability *) info];
//
//    [pool release];
//
//} // ReachabilityCallback()
//
//
//
//
////- (BOOL) isEqual: (BmobReachability *) r {
////
////    return [r.key isEqualToString: self.key];
////
////} // isEqual:
//
//
//#pragma mark -
//#pragma mark Reachability Allocation Methods
//
//+ (NSString *) makeAddressKey: (in_addr_t) addr {
//    // addr is assumed to be in network byte order.
//
//    static const int       highShift    = 24;
//    static const int       highMidShift = 16;
//    static const int       lowMidShift  =  8;
//    static const in_addr_t mask         = 0x000000ff;
//
//    addr = ntohl(addr);
//
//    return [NSString stringWithFormat: @"%d.%d.%d.%d",
//            (addr >> highShift)    & mask,
//            (addr >> highMidShift) & mask,
//            (addr >> lowMidShift)  & mask,
//            addr                  & mask];
//
//} // makeAddressKey:
//
//#pragma mark -
//#pragma mark Network Flag Handling Methods
//
//
//#if USE_DDG_EXTENSIONS
////
//// iPhone condition codes as reported by a 3GS running iPhone OS v3.0.
//// Airplane Mode turned on:  Reachability Flag Status: -- -------
//// WWAN Active:              Reachability Flag Status: WR -t-----
//// WWAN Connection required: Reachability Flag Status: WR ct-----
////         WiFi turned on:   Reachability Flag Status: -R ------- Reachable.
//// Local   WiFi turned on:   Reachability Flag Status: -R xxxxxxd Reachable.
////         WiFi turned on:   Reachability Flag Status: -R ct----- Connection down. (Non-intuitive, empirically determined answer.)
//const SCNetworkReachabilityFlags bmobkConnectionDown =  kSCNetworkReachabilityFlagsConnectionRequired |
//kSCNetworkReachabilityFlagsTransientConnection;
////         WiFi turned on:   Reachability Flag Status: -R ct-i--- Reachable but it will require user intervention (e.g. enter a WiFi password).
////         WiFi turned on:   Reachability Flag Status: -R -t----- Reachable via VPN.
////
//// In the below method, an 'x' in the flag status means I don't care about its value.
////
//// This method differs from Apple's by testing explicitly for empirically observed values.
//// This gives me more confidence in it's correct behavior. Apple's code covers more cases
//// than mine. My code covers the cases that occur.
////
//- (NetworkStatus) networkStatusForFlags: (SCNetworkReachabilityFlags) flags {
//
//    if (flags & kSCNetworkReachabilityFlagsReachable) {
//
//        // Local WiFi -- Test derived from Apple's code: -localWiFiStatusForFlags:.
//        if (self.key == bmobkLocalWiFiConnection) {
//
//            // Reachability Flag Status: xR xxxxxxd Reachable.
//            return (flags & kSCNetworkReachabilityFlagsIsDirect) ? kReachableViaWiFi : kNotReachable;
//
//        }
//
//        // Observed WWAN Values:
//        // WWAN Active:              Reachability Flag Status: WR -t-----
//        // WWAN Connection required: Reachability Flag Status: WR ct-----
//        //
//        // Test Value: Reachability Flag Status: WR xxxxxxx
//        if (flags & kSCNetworkReachabilityFlagsIsWWAN) { return kReachableViaWWAN; }
//
//        // Clear moot bits.
//        flags &= ~kSCNetworkReachabilityFlagsReachable;
//        flags &= ~kSCNetworkReachabilityFlagsIsDirect;
//        flags &= ~kSCNetworkReachabilityFlagsIsLocalAddress; // kInternetConnection is local.
//
//        // Reachability Flag Status: -R ct---xx Connection down.
//        if (flags == bmobkConnectionDown) { return kNotReachable; }
//
//        // Reachability Flag Status: -R -t---xx Reachable. WiFi + VPN(is up) (Thank you Ling Wang)
//        if (flags & kSCNetworkReachabilityFlagsTransientConnection)  { return kReachableViaWiFi; }
//
//        // Reachability Flag Status: -R -----xx Reachable.
//        if (flags == 0) { return kReachableViaWiFi; }
//
//        // Apple's code tests for dynamic connection types here. I don't.
//        // If a connection is required, regardless of whether it is on demand or not, it is a WiFi connection.
//        // If you care whether a connection needs to be brought up,   use -isConnectionRequired.
//        // If you care about whether user intervention is necessary,  use -isInterventionRequired.
//        // If you care about dynamically establishing the connection, use -isConnectionIsOnDemand.
//
//        // Reachability Flag Status: -R cxxxxxx Reachable.
//        if (flags & kSCNetworkReachabilityFlagsConnectionRequired) { return kReachableViaWiFi; }
//
//        // Required by the compiler. Should never get here. Default to not connected.
//#if (defined DEBUG && defined CLASS_DEBUG)
//        NSAssert1(NO, @"Uncaught reachability test. Flags: %@", reachabilityFlags_(flags));
//#endif
//        return kNotReachable;
//
//    }
//
//    // Reachability Flag Status: x- xxxxxxx
//    return kNotReachable;
//
//} // networkStatusForFlags:
//
//
//
//- (BOOL) connectionRequired {
//
//    return [self isConnectionRequired];
//
//} // connectionRequired
//#endif
//
//
//#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 30000)
//static const SCNetworkReachabilityFlags kOnDemandConnection = kSCNetworkReachabilityFlagsConnectionOnTraffic |
//                                                              kSCNetworkReachabilityFlagsConnectionOnDemand;
//#else
//static const SCNetworkReachabilityFlags kOnDemandConnection = kSCNetworkReachabilityFlagsConnectionAutomatic;
//#endif
//
//
//#pragma mark -
//#pragma mark Apple's Network Flag Handling Methods
//
//
//#if !USE_DDG_EXTENSIONS
///*
// *
// *  Apple's Network Status testing code.
// *  The only changes that have been made are to use the new logReachabilityFlags macro and
// *  test for local WiFi via the key instead of Apple's boolean. Also, Apple's code was for v3.0 only
// *  iPhone OS. v2.2.1 and earlier conditional compiling is turned on. Hence, to mirror Apple's behavior,
// *  set your Base SDK to v3.0 or higher.
// *
// */
//
//- (NetworkStatus) localWiFiStatusForFlags: (SCNetworkReachabilityFlags) flags
//{
//    logReachabilityFlags(flags);
//
//    BOOL retVal = NotReachable;
//    if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
//    {
//        retVal = ReachableViaWiFi;
//    }
//    return retVal;
//}
//
//
//- (NetworkStatus) networkStatusForFlags: (SCNetworkReachabilityFlags) flags
//{
//    logReachabilityFlags(flags);
//    if (!(flags & kSCNetworkReachabilityFlagsReachable))
//    {
//        // if target host is not reachable
//        return NotReachable;
//    }
//
//    BOOL retVal = NotReachable;
//
//    if (!(flags & kSCNetworkReachabilityFlagsConnectionRequired))
//    {
//        // if target host is reachable and no connection is required
//        //  then we'll assume (for now) that your on Wi-Fi
//        retVal = ReachableViaWiFi;
//    }
//
//#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 30000) // Apple advises you to use the magic number instead of a symbol.
//    if ((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) ||
//        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic))
//#else
//    if (flags & kSCNetworkReachabilityFlagsConnectionAutomatic)
//#endif
//        {
//            // ... and the connection is on-demand (or on-traffic) if the
//            //     calling application is using the CFSocketStream or higher APIs
//
//            if (!(flags & kSCNetworkReachabilityFlagsInterventionRequired))
//            {
//                // ... and no [user] intervention is needed
//                retVal = ReachableViaWiFi;
//            }
//        }
//
//    if (flags & kSCNetworkReachabilityFlagsIsWWAN)
//    {
//        // ... but WWAN connections are OK if the calling application
//        //     is using the CFNetwork (CFSocketStream?) APIs.
//        retVal = ReachableViaWWAN;
//    }
//    return retVal;
//}
//
//
//
//
//
//- (BOOL) isReachable {
//
//    NSAssert(reachabilityRef, @"isReachable called with NULL reachabilityRef");
//
//    SCNetworkReachabilityFlags flags = 0;
//    NetworkStatus status = kNotReachable;
//
//    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
//
//        logReachabilityFlags(flags);
//
//        if(self.key == kLocalWiFiConnection) {
//
//            status = [self localWiFiStatusForFlags: flags];
//
//        } else {
//
//            status = [self networkStatusForFlags: flags];
//
//        }
//
//        return (kNotReachable != status);
//
//    }
//
//    return NO;
//
//} // isReachable
//
//
//- (BOOL) isConnectionRequired {
//
//    return [self connectionRequired];
//
//} // isConnectionRequired
//
//
//- (BOOL) connectionRequired {
//
//    NSAssert(reachabilityRef, @"connectionRequired called with NULL reachabilityRef");
//
//    SCNetworkReachabilityFlags flags;
//
//    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
//
//        logReachabilityFlags(flags);
//
//        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
//
//    }
//
//    return NO;
//
//} // connectionRequired
//#endif

@end
