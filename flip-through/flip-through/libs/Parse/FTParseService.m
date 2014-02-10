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
    }
    return self;
}



- (void)configureWithLaunchOptions:(NSDictionary *)launchOptions finishBlock:(void (^)())finishBlock;
{
    __weak typeof(self) wself = self;

    __block PFUser *user = [PFUser currentUser];
    
    void(^blockAfterSave)(BOOL succeeded, NSError *error) = ^(BOOL succeeded, NSError *error) 
    {
        PFACL *defaultACL = [PFACL ACL];
        
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
        
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

        [wself querysWithErrorBlock:^(NSString *errorMessage) 
        {
            wself.isUpdating = NO;
            FTAppDelegate *appDelegate = (FTAppDelegate *) [UIApplication sharedApplication].delegate;
            
            [FTAlert alertWithFrame:appDelegate.window.frame title:@"Warning!" message:errorMessage leftTitle:@"Ok" leftBlock:^{} rightTitle:nil rightBlock:nil];
            
        } finishBlock:finishBlock];
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



- (void)querysWithErrorBlock:(void (^)(NSString *errorMessage))errorBlock finishBlock:(void (^)())finishBlock;
{
    if (self.isUpdating)
    {
        return;
    }    
    __block void(^bfinishBlock)() = finishBlock;

    self.isUpdating = YES;
    __weak typeof(self) wself = self;
    
    [wself queryConfig:errorBlock successBlock:^{
        FTLog(@"Finished with Config");

        wself.isUpdating = NO;
        
        if (bfinishBlock)
        {
            bfinishBlock();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:FTParseServiceQueryDidFinishNotification object:nil];
        
    }];
}




- (void)queryConfig:(void (^)(NSString *errorMessage))errorBlock successBlock:(void (^)())successBlock;
{    
    PFQuery *query = [PFQuery queryWithClassName:@"ft_config"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error)
        {
            FTLog(@"error = %@", error);
            errorBlock([error parseError]);
            return;
        }
        else
        {
            if (objects.count)
            {
                _config = [[FTConfig alloc] initWithPFObject:objects.firstObject];
                if (!_config)
                {
                    FTLog(@"Cannot get config");
                }
            }
        }
        successBlock();
    }];
}




@end
