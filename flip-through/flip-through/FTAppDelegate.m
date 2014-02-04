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

@implementation FTAppDelegate
{
    Reachability *_reachability;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
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
        [FTAlert alertWithFrame:self.window.frame title:@"Oops!" message:@"No internet connection found. Please check and try again." leftTitle:@"Ok" leftBlock:^{} rightTitle:nil rightBlock:nil];
    }
}


- (BOOL)setupNetwork
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleNetworkStatusChangedNotification:) name:kReachabilityChangedNotification object: nil];
    
    _reachability = [Reachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    
    if (![Reachability isNetworkAvailable])
    {
        [FTAlert alertWithFrame:self.window.frame title:@"Oops!" message:@"No internet connection found. Please check and try again." leftTitle:@"Ok" leftBlock:^{} rightTitle:nil rightBlock:nil];
        return NO;
    }
    return YES;
}


@end
