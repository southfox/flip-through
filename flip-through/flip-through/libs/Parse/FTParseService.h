//
//  FTParseService.h
//  FT
//
//  Created by Javier Fuchs on 2/5/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FTParseServiceQueryDidFinishNotification;

@class PFUser;
@class FTConfig;

@interface FTParseService : NSObject 

+ (FTParseService *)sharedInstance;

@property (nonatomic, strong, readonly) FTConfig *config;
@property (nonatomic) BOOL isUpdating;

- (PFUser *)currentUser;
- (NSString *)email;
- (NSString *)username;
- (BOOL)isAuthenticated;


- (void)querys:(void (^)(BOOL succeeded, NSError *error))finishBlock;

- (void)configureWithLaunchOptions:(NSDictionary *)launchOptions finishBlock:(void (^)(BOOL succeeded, NSError *error))finishBlock;

+ (void)logEvent:(NSString*)event;
+ (void)logEvent:(NSString*)event withParameters:(NSDictionary*)dict;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
- (void)applicationDidBecomeActive:(UIApplication *)application;

- (void)logout;
- (BOOL)isLoggedInWithFacebook;

@end
