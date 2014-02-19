//
//  FTParseService.m
//  FT
//
//  Created by Javier Fuchs on 2/5/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTParseService.h"
#import <Parse/Parse.h>
#import "FTConfig.h"
#import "NSArray+FT.h"
#import "NSError+FT.h"
#import "FTAlert.h"
#import "FTAppDelegate.h"
#import "FTFacebookService.h"

#define kParseApplicationId     @"cHuByJ3APDGFWCqKPopK9J8QAVoLno9OUwn2Vlm9"
#define kParseClientKey         @"3YmEB3qI7P2sT9zB8obSiyFFnntQ2yobEegI1iE5"


NSString *const FTParseServiceQueryDidFinishNotification = @"FTParseServiceQueryDidFinishNotification";

@interface FTParseService ()

@end

@implementation FTParseService
{
}

+ (FTParseService *)sharedInstance
{
    static FTParseService *_sharedInstance = nil;
    
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


- (id)init
{
    self = [super init];
    if (self) {
        [Parse setApplicationId:kParseApplicationId clientKey:kParseClientKey];
        [PFFacebookUtils initializeFacebook];
    }
    return self;
}



- (void)configureWithLaunchOptions:(NSDictionary *)launchOptions finishBlock:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    __weak typeof(self) wself = self;

    __block PFUser *user = [PFUser currentUser];
    
    void(^blockAfterSave)(BOOL succeeded, NSError *error) = ^(BOOL succeeded, NSError *error) 
    {
        PFACL *defaultACL = [PFACL ACL];
        
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
        
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

        [wself querys:^(BOOL succeeded, NSError *error) {
            wself.isUpdating = NO;
            if ([wself isLoggedInWithFacebook])
            {
                finishBlock(YES, nil);
            }
            else
            {
                [wself loginFacebookWithFinishBlock:finishBlock];
            }
        }];
    };
    
    if ([user username])
    {
        blockAfterSave(YES, nil);
    }
    else
    {
        [PFUser enableAutomaticUser];
        user = [PFUser currentUser];
        
        [user saveInBackgroundWithBlock:blockAfterSave];
    }
    FTLog(@"user = %@", user);
    
}

+ (void)logEvent:(NSString*)event;
{
    [PFAnalytics trackEvent:event];
}


+ (void)logEvent:(NSString*)event withParameters:(NSDictionary*)dict;
{
    // PFAnalytics receives only 4 parameters, and should be strings
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    int i = 0;
    for (NSString *key in dict.allKeys)
    {
        id value = dict[key];
        FTAssert(value && [value isKindOfClass:[NSString class]]);
        [params setObject:value forKey:key];
        i++;
        if (i >= 4)
        {
            break;
        }
    }
    [PFAnalytics trackEvent:event dimensions:params];
}

- (PFUser *)currentUser;
{
    return [PFUser currentUser];
}


- (NSString *)email;
{
    PFUser *user = [PFUser currentUser];
    return [user email];
}


- (NSString *)username;
{
    PFUser *user = [PFUser currentUser];
    return [user username];
}



- (BOOL)isAuthenticated;
{
    PFUser *user = [PFUser currentUser];
    return [user isAuthenticated];
}



- (void)querys:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    if (self.isUpdating)
    {
        return;
    }    
    __block void(^bfinishBlock)(BOOL succeeded, NSError *error) = finishBlock;

    self.isUpdating = YES;
    __weak typeof(self) wself = self;
    
    [wself queryConfig:^(BOOL succeeded, NSError *error) {
        FTLog(@"Finished with Config");
        
        if (bfinishBlock)
        {
            bfinishBlock(succeeded, error);
        }
        wself.isUpdating = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:FTParseServiceQueryDidFinishNotification object:nil];
        
    }];
}




- (void)queryConfig:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{    
    PFQuery *query = [PFQuery queryWithClassName:@"ft_config"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error)
        {
            FTLog(@"error = %@", error);
            finishBlock(NO, error);
            return;
        }
        else
        {
            if (objects.count)
            {
                _config = [[FTConfig alloc] initWithPFObject:objects.firstObject];
                if (!_config)
                {
                    finishBlock(NO, [NSError errorWithMessage:@"cannot get config"]);
                }
                else
                {
                    finishBlock(YES, nil);
                }
            }
            else
            {
                finishBlock(NO, [NSError errorWithMessage:@"cannot get config"]);
            }
        }
    }];
}


#pragma mark -
#pragma mark facebook integration with parse

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
{
    if ([self.config isFacebookEnabled])
    {
        return [FTFacebookService handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    }
    return NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application;
{
    [FTFacebookService handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}


- (void)loginFacebookWithFinishBlock:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    // The permissions requested from the user
    NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"publish_stream", @"publish_actions", @"photo_upload"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user)
        {
            if (!error)
            {
                finishBlock(NO, [NSError errorWithMessage:@"The user cancelled the Facebook login."]);
            } else {
                finishBlock(NO, error);
            }
        }
        else if (user.isNew)
        {
            // User with facebook signed up and logged in!
            [[FTFacebookService sharedInstance] request:finishBlock];
        }
        else
        {
            // User with facebook logged in!
            [[FTFacebookService sharedInstance] request:finishBlock];
        }
    }];
}


- (void)logout;
{
    [PFUser logOut];
}


- (BOOL)isLoggedInWithFacebook;
{
    return [PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
}

- (void)linkUserWithFacebook:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:nil block:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                finishBlock(YES, nil);
            }
            else
            {
                finishBlock(NO, error);
            }
        }];
    }
}

@end
