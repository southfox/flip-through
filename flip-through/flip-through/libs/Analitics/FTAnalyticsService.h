//
//  FTAnalyticsService.h
//  FT
//
//  Created by Javier Fuchs on 2/7/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FTLogViewEvent(event, key, value) \
[[FTAnalyticsService sharedInstance] logEvent:event withParameters:@{@"view" : NSStringFromClass([self class]), @"fnc" : [NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__], key: value}];

@interface FTAnalyticsService : NSObject

+ (FTAnalyticsService *)sharedInstance;

- (void)configure;

- (void)logEvent:(NSString*)event;
- (void)logEvent:(NSString*)event withParameters:(NSDictionary*)dict;
- (void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception;
- (void)logError:(NSString *)errorID message:(NSString *)message error:(NSError *)error;

@end
