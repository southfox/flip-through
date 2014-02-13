//
//  FTCrashService.m
//  FT
//
//  Created by Javier Fuchs on 2/13/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTCrashService.h"
#import "FTConfig.h"
#import "Crittercism.h"
#import "FTParseService.h"
#import <Crashlytics/Crashlytics.h>

@interface FTCrashService ()
@end

@implementation FTCrashService

+ (FTCrashService *)sharedInstance
{
    static FTCrashService *_sharedInstance = nil;
    
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
    
    if ([config isCrittercismEnabled])
    {
        [Crittercism enableWithAppID:[config crittercismAppId]];
    }
    
    if ([config isCrashlyticsEnabled])
    {
        [Crashlytics startWithAPIKey:[config crashlyticsAppId]];
    }
    
}






@end
