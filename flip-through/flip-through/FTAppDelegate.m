//
//  FTAppDelegate.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTAppDelegate.h"
#import "Reachability+FT.h"
#import "FTAlert.h"
#import "FTGridViewController.h"

// services
#import "FTFlickrPublicFeedService.h"
#import "FTParseService.h"
#import "FTAnalyticsService.h"
#import "FTCrashService.h"


@implementation FTAppDelegate
{
    Reachability *_reachability;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{


    if ([self configureNetwork])
    {
        __weak typeof(self) wself = self;
        
        [self configureParseServiceWithOptions:launchOptions finishBlock:^{
            // Once finished, configure the other services

            [wself configureCrashService];

            [wself configureAnalyticsService];

            // flickr feed
            [wself configureFlikrPublicFeedService];
            
            // configure data
            [wself configureDataService];

        }];
    }
    
    [self configureWindow];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    if ([Reachability isNetworkAvailable])
    {
        // TODO: get the flickr feed here
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark -
#pragma mark private methods: Networking

- (void)handleNetworkStatusChangedNotification:(NSNotification *)notification
{
    if ([Reachability isNetworkAvailable])
    {
        FTLog(@"network is available now");

        // TODO: add the refresh here
    }
    else
    {
        [self showNoNetworkAlert];
    }
}


- (BOOL)configureNetwork
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleNetworkStatusChangedNotification:) name:kReachabilityChangedNotification object: nil];
    
    _reachability = [Reachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    
    if (![Reachability isNetworkAvailable])
    {
        [self showNoNetworkAlert];
        return NO;
    }
    return YES;
}

- (void)showNoNetworkAlert;
{
    FTLogViewEvent(@"SERVICE", @"status", @"no_network");

    [FTAlert alertWithFrame:self.window.frame title:@"Oops!" message:@"No internet connection found. Please check and try again." leftTitle:@"Ok" leftBlock:^{} rightTitle:nil rightBlock:nil];
}

#pragma mark -
#pragma mark Parse service

- (void)configureParseServiceWithOptions:(NSDictionary *)launchOptions finishBlock:(void (^)())finishBlock;
{
    [[FTParseService sharedInstance] configureWithLaunchOptions:launchOptions finishBlock:finishBlock];
}



#pragma mark -
#pragma mark Flickr service

- (void)configureFlikrPublicFeedService;
{
    FTLogViewEvent(@"SERVICE", @"service", @"flickr");

    [[FTFlickrPublicFeedService sharedInstance] configure];
}


#pragma mark -
#pragma mark Crash service

- (void)configureCrashService;
{
    [[FTCrashService sharedInstance] configure];
}

#pragma mark -
#pragma mark Analytics service

- (void)configureAnalyticsService;
{
    [[FTAnalyticsService sharedInstance] configure];

    NSString *username = [[FTParseService sharedInstance] username];
    if (username)
    {
        FTLogViewEvent(@"START", @"user", username);
    }
    else
    {
        FTLogViewEvent(@"INSTALL", @"user", username);
    }
    
}



#pragma mark -
#pragma mark window

- (void)configureWindow
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    FTGridViewController *viewController = [[FTGridViewController alloc] init];
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
}


#pragma mark -
#pragma mark data

- (void)configureDataService;
{

}


@end
