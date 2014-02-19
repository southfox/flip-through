//
//  FTConfig.m
//  flip-through
//
//  Created by Javier Fuchs on 2/7/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTConfig.h"
#import "FTPFObject.h"
#import <Parse/Parse.h>
#import <RestKit.h>

@implementation FTConfig
{
}


- (id)initWithPFObject:(PFObject *)object
{
    self = [super initWithPFObject:object];
    if (self) {
        _flickrFeedUrl = [object objectForKey:@"flickrFeedUrl"];
        FTAssert(_flickrFeedUrl);
        _flickrFeedPath = [object objectForKey:@"flickrFeedPath"];
        FTAssert(_flickrFeedPath);
        _flickrFeedParam = [object objectForKey:@"flickrFeedParam"];
        FTAssert(_flickrFeedParam);
        _aviaryAPIKey = [object objectForKey:@"aviaryAPIKey"];
        FTAssert(_aviaryAPIKey);
        _aviaryInAppPurchasesEnabled = [object objectForKey:@"aviaryInAppPurchasesEnabled"];
        FTAssert(_aviaryInAppPurchasesEnabled);
        _facebookEnabled = [object objectForKey:@"facebookEnabled"];
        FTAssert(_facebookEnabled);
        _facebookAppId = [object objectForKey:@"facebookAppId"];
        FTAssert(_facebookAppId);
        _flurryAppKey = [object objectForKey:@"flurryAppKey"];
        FTAssert(_flurryAppKey);
        _flurryEnabled = [object objectForKey:@"flurryEnabled"];
        FTAssert(_flurryEnabled);
        _googleAnalyticsEnabled = [object objectForKey:@"googleAnalyticsEnabled"];
        FTAssert(_googleAnalyticsEnabled);
        _googleAnalyticsTrackingId = [object objectForKey:@"googleAnalyticsTrackingId"];
        FTAssert(_googleAnalyticsTrackingId);
        _parseLogEnabled = [object objectForKey:@"parseLogEnabled"];
        FTAssert(_parseLogEnabled);
        _crittercismEnabled = [object objectForKey:@"crittercismEnabled"];
        FTAssert(_crittercismEnabled);
        _crittercismAppId = [object objectForKey:@"crittercismAppId"];
        FTAssert(_crittercismAppId);
        _crashlyticsEnabled = [object objectForKey:@"crashlyticsEnabled"];
        FTAssert(_crittercismEnabled);
        _crashlyticsAppId = [object objectForKey:@"crashlyticsAppId"];
        FTAssert(_crashlyticsAppId);
        _testFlightEnabled = [object objectForKey:@"testFlightEnabled"];
        FTAssert(_testFlightEnabled);
        _testFlightApplicationToken = [object objectForKey:@"testFlightApplicationToken"];
        FTAssert(_testFlightApplicationToken);
        _linkedInEnabled = [object objectForKey:@"linkedInEnabled"];
        FTAssert(_linkedInEnabled);
        _linkedInApiKey = [object objectForKey:@"linkedInApiKey"];
        FTAssert(_linkedInApiKey);
        _linkedInStateAntiCrossSiteRequestForgery = [object objectForKey:@"linkedInStateAntiCrossSiteRequestForgery"];
        FTAssert(_linkedInStateAntiCrossSiteRequestForgery);
        _linkedInOAuthUserSecret = [object objectForKey:@"linkedInOAuthUserSecret"];
        FTAssert(_linkedInOAuthUserSecret);
        _linkedInOAuthUserToken = [object objectForKey:@"linkedInOAuthUserToken"];
        FTAssert(_linkedInOAuthUserToken);
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@", self.flurryEnabled, self.googleAnalyticsEnabled, self.parseLogEnabled, self.crittercismEnabled, self.crashlyticsEnabled, self.testFlightEnabled, self.linkedInEnabled, self.linkedInApiKey];
}

- (BOOL)isAviaryInAppPurchasesEnabled;
{
    return [self.aviaryInAppPurchasesEnabled boolValue];
}

- (BOOL)isFacebookEnabled;
{
    return [self.facebookEnabled boolValue];
}

- (BOOL)isFlurryEnabled;
{
    return [self.flurryEnabled boolValue];
}

- (BOOL)isGoogleAnalyticsEnabled;
{
    return [self.googleAnalyticsEnabled boolValue];
}

- (BOOL)isParseLogEnabled;
{
    return [self.parseLogEnabled boolValue];
}


- (BOOL)isCrittercismEnabled;
{
    return [self.crittercismEnabled boolValue];
}

- (BOOL)isCrashlyticsEnabled;
{
    return [self.crashlyticsEnabled boolValue];
}

- (BOOL)isTestFlightEnabled;
{
    return [self.testFlightEnabled boolValue];
}

- (BOOL)isLinkedInEnabled;
{
    return [self.linkedInEnabled boolValue];
}

@end

