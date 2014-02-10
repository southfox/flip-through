//
//  FTAnalyticsService.m
//  FT
//
//  Created by Javier Fuchs on 2/7/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTAnalyticsService.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreLocation/CoreLocation.h>
#import "FTParseService.h"
#import "FTConfig.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "Reachability+FT.h"
#import "Crittercism.h"

#define kEventDeviceInfo @"device_info"

static BOOL configured = NO;

@interface FTAnalyticsService ()
@end

@implementation FTAnalyticsService

+ (FTAnalyticsService *)sharedInstance
{
    static FTAnalyticsService *_sharedInstance = nil;
    
    @synchronized (self)
    {
        if (_sharedInstance == nil)
        {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    FTAssert(_sharedInstance != nil);
    
    return _sharedInstance;
}



- (void)configure;
{

    FTConfig *config = [[FTParseService sharedInstance] config];
    FTAssert(config && [config isKindOfClass:[FTConfig class]]);
    
	if (!configured)
    {
        if ([config isFlurryEnabled])
        {
            // set YES for debug INFO.
    #ifdef DEBUG
            [Flurry setDebugLogEnabled:YES];
            [Flurry setShowErrorInLogEnabled:YES];
    #else
            [Flurry setDebugLogEnabled:NO];
            [Flurry setShowErrorInLogEnabled:NO];
    #endif
            
            // Override the app version
            NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            [Flurry setAppVersion:bundleVersion];
            
            // user's id in your system
            NSString *username = [[FTParseService sharedInstance] username];
            
            if (username)
            {
                [Flurry setUserID:username];
            }
            
            // start Session
            [Flurry startSession:[config flurryAppKey]];
        }
        
        if ([config isGoogleAnalyticsEnabled])
        {
            [self configureGoogleAnalytics];
        }
        
        if ([config isCrittercismEnabled])
        {
            [Crittercism enableWithAppID:[config crittercismAppId]];
        }
        
        
        [self startSession];
        
        [self sendDeviceInformation];
        
        configured = YES;
        
    }
}




//+ (void)sendLocation
//{
//    CLLocation *location = [[FTLocationManager sharedInstance] currentLocation];
//    [Flurry  setLatitude:location.coordinate.latitude
//               longitude:location.coordinate.longitude
//      horizontalAccuracy:location.horizontalAccuracy
//        verticalAccuracy:location.verticalAccuracy];
//
//}



/*
 * Send device information
 * v_maj - Major App version. 128 char string
 * v_min - Minor App Version. 128 char string
 * v_rev - revision App version. 128 char string
 * c - carrier name. String
 *
 * The v_maj, v_min and v_rev are numbers that correspond to versioning your app [v_maj].[v_min].[v_rev].
 */


- (void)sendDeviceInformation
{
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    [param setObject:@"0" forKey:@"v_maj"];
    [param setObject:@"0" forKey:@"v_min"];
    [param setObject:@"0" forKey:@"v_rev"];
    
    // get version separated in components
    [self getVersionInParameters:param];
    
    // get carrier name
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    if (netinfo) 
    {
        CTCarrier *carrier = [netinfo subscriberCellularProvider];
        if (carrier) 
        {
            [param setObject:[carrier carrierName] forKey:@"carrier"];
        }
    }
    
    FTLog(@"deviceinfo dict = %@", param);
	[self logEvent:kEventDeviceInfo withParameters:param];
}


- (void)getVersionInParameters:(NSMutableDictionary* )param
{
    __block NSMutableDictionary* bparam = param;
    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSArray* version = [bundleVersion componentsSeparatedByString:@"."];
    [version enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
    {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString* str = (NSString*)obj;
            switch (idx) {
                case 0:
                    [bparam setObject:str forKey:@"v_maj"];
                    break;
                case 1:
                    [bparam setObject:str forKey:@"v_min"];
                    break;
                case 2:
                    [bparam setObject:str forKey:@"v_rev"];
                    break;
                default:
                    break;
            }
        }
    }];
}


// custom event
- (void)logEvent:(NSString*)event;
{
    FTConfig *config = [[FTParseService sharedInstance] config];
    FTAssert(config && [config isKindOfClass:[FTConfig class]]);

    if ([config isFlurryEnabled])
    {
        [Flurry logEvent:event];
    }
    
    if ([config isParseLogEnabled])
    {
        [FTParseService logEvent:event];
    }
    
    if ([config isGoogleAnalyticsEnabled])
    {
        id<GAITracker> gaiTracker = [[GAI sharedInstance] defaultTracker];

        [gaiTracker set:kGAIScreenName value:event];

        [gaiTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"    // Event category (required)
                                                              action:event              // Event action (required)
                                                               label:nil                // Event label
                                                               value:nil] build]];      // Event value
        
    }
    
    if ([config isCrittercismEnabled])
    {
        
        NSString *breadcrumb = [NSString stringWithFormat:@"<event %@>", event];
        NSString* username = [[FTParseService sharedInstance] username];
        
        if (username && [username length])
        {
            [Crittercism setUsername:username];
        }

        [Crittercism leaveBreadcrumb:breadcrumb];

    }

}

- (void)logEvent:(NSString*)event withParameters:(NSDictionary*)dict;
{
    [self logEvent:event];

    FTConfig *config = [[FTParseService sharedInstance] config];
    FTAssert(config && [config isKindOfClass:[FTConfig class]]);
    
#ifdef DEBUG
    for (NSString *key in dict.allKeys)
    {
        id value = dict[key];
        FTAssert(value && [value isKindOfClass:[NSString class]]);
    }
    
#endif

    if ([config isFlurryEnabled])
    {
        [Flurry logEvent:event withParameters:dict];
    }
    
    if ([config isParseLogEnabled])
    {
        [FTParseService logEvent:event withParameters:dict];
    }
    
    if ([config isGoogleAnalyticsEnabled])
    {
        id<GAITracker> gaiTracker = [[GAI sharedInstance] defaultTracker];
        
        for (NSString *key in dict.allKeys)
        {
            [gaiTracker set:key value:dict[key]];
        }

        [gaiTracker set:kGAIScreenName value:event];

        [gaiTracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
}


- (void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception;
{
    FTConfig *config = [[FTParseService sharedInstance] config];
    FTAssert(config && [config isKindOfClass:[FTConfig class]]);
    
    if ([config isFlurryEnabled])
    {
        [Flurry logError:errorID message:message exception:exception];
    }
    
    if ([config isParseLogEnabled])
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:errorID forKey:@"errorID"];
        [dict setObject:message forKey:@"message"];
        if (exception.reason)
        {
            [dict setObject:exception.reason forKey:@"reason"];
        }
        if (exception.name)
        {
            [dict setObject:exception.name forKey:@"name"];
        }
        [FTParseService logEvent:@"Exception" withParameters:dict];
    }
    
}


- (void)logError:(NSString *)errorID message:(NSString *)message error:(NSError *)error;
{
    FTConfig *config = [[FTParseService sharedInstance] config];
    FTAssert(config && [config isKindOfClass:[FTConfig class]]);
    
    if ([config isFlurryEnabled])
    {
        [Flurry logError:errorID message:message error:error];
    }
    
    if ([config isParseLogEnabled])
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:errorID forKey:@"errorID"];
        [dict setObject:message forKey:@"message"];
        if (error.code)
        {
            [dict setObject:[NSString stringWithFormat:@"%d", (int)error.code] forKey:@"code"];
        }
        if (error.localizedDescription)
        {
            [dict setObject:error.localizedDescription forKey:@"localizedDescription"];
        }
        [FTParseService logEvent:@"Error" withParameters:dict];
    }
}


- (BOOL)userDefaultFirstTimeLogEvent:(NSString*)event {
	NSString* key = [NSString stringWithFormat:@"current-analytics-first-time-%@", event];
	NSNumber* value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	if (value == nil) {
		// simply save the key in the standard user defaults with any value
		[[NSUserDefaults standardUserDefaults] setObject:@"DONE" forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
		return YES;
	}
	return NO;
}


#pragma mark -
#pragma mark events

- (void)startSession;
{
    [self logEvent:@"start_application"];
}


#pragma mark -
#pragma mark google analytics

#pragma mark -
#pragma mark Google Analitics

- (void)configureGoogleAnalytics;
{
    FTConfig *config = [[FTParseService sharedInstance] config];
    FTAssert(config && [config isKindOfClass:[FTConfig class]]);
    
    // Initialize Google Analytics with a 120-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
#ifdef DEBUG
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
#endif

    [[GAI sharedInstance] trackerWithTrackingId:[config googleAnalyticsTrackingId]];
}


@end
