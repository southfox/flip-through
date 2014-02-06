//
//  FTParseManager.h
//  FT
//
//  Created by Javier Fuchs on 2/5/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FTParseManagerQueryDidFinishNotification;

@class FTConfig;

@interface FTParseManager : NSObject 

@property (nonatomic, strong, readonly) FTConfig *config;
@property (nonatomic) BOOL isUpdating;
@property (nonatomic) BOOL isInitialized;
@property (nonatomic) BOOL isLoggedIn;

- (NSString *)email;
- (NSString *)username;
- (BOOL)isAuthenticated;

+ (FTParseManager *)sharedInstance;

- (void)querysWithErrorBlock:(void (^)(NSString *errorMessage))errorBlock finishBlock:(void (^)())finishBlock;

- (void)startWithLaunchOptions:(NSDictionary *)launchOptions finishBlock:(void (^)())finishBlock;

+ (void)logEvent:(NSString*)event;
+ (void)logEvent:(NSString*)event withParameters:(NSDictionary*)dict;

@end
