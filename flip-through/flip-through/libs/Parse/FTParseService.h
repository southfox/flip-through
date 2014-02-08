//
//  FTParseService.h
//  FT
//
//  Created by Javier Fuchs on 2/5/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FTParseServiceQueryDidFinishNotification;

@class FTConfig;

@interface FTParseService : NSObject 

+ (FTParseService *)sharedInstance;

@property (nonatomic, strong, readonly) FTConfig *config;
@property (nonatomic) BOOL isUpdating;

- (NSString *)email;
- (NSString *)username;
- (BOOL)isAuthenticated;


- (void)querysWithErrorBlock:(void (^)(NSString *errorMessage))errorBlock finishBlock:(void (^)())finishBlock;

- (void)configureWithLaunchOptions:(NSDictionary *)launchOptions finishBlock:(void (^)())finishBlock;

+ (void)logEvent:(NSString*)event;
+ (void)logEvent:(NSString*)event withParameters:(NSDictionary*)dict;

@end
