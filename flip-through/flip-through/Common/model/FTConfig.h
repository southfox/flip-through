//
//  FTConfig.h
//  flip-through
//
//  Created by Javier Fuchs on 2/7/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTPFObject.h"

@class PFObject;

@interface FTConfig : FTPFObject

@property (nonatomic, copy) NSString *flickrFeedUrl;
@property (nonatomic, copy) NSString *flickrFeedPath;
@property (nonatomic, copy) NSString *flickrFeedParam;
@property (nonatomic, copy) NSString *aviaryAPIKey;
@property (nonatomic, copy) NSString *facebookAppId;
@property (nonatomic, copy) NSString *flurryAppKey;
@property (nonatomic, copy) NSNumber *flurryEnabled;
@property (nonatomic, copy) NSNumber *googleAnalyticsEnabled;
@property (nonatomic, copy) NSString *googleAnalyticsTrackingId;
@property (nonatomic, copy) NSNumber *parseLogEnabled;
@property (nonatomic, copy) NSNumber *crittercismEnabled;
@property (nonatomic, copy) NSString *crittercismAppId;

- (id)initWithPFObject:(PFObject *)object;

- (BOOL)isFlurryEnabled;

- (BOOL)isParseLogEnabled;

- (BOOL)isGoogleAnalyticsEnabled;

- (BOOL)isCrittercismEnabled;

@end