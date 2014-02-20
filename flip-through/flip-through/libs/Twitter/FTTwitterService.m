//
//  FTTwitterService.m
//  FT
//
//  Created by Javier Fuchs on 2/19/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTTwitterService.h"
#import "FTParseService.h"
#import "FTConfig.h"
#import <Social/Social.h>


@interface FTTwitterService ()
@end

@implementation FTTwitterService

+ (FTTwitterService *)sharedInstance
{
    static FTTwitterService *_sharedInstance = nil;
    
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



- (void)configure;
{
}

- (void)post:(UIImage *)image title:(NSString *)title viewController:(UIViewController *)viewController completion:(void (^)())completion;
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *composer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
//        fbComposer.completionHandler = ^(SLComposeViewControllerResult result) {
//            wself.facebookButton.enabled = YES;
//            wself.twitterButton.enabled = YES;
//        };
        
        [composer setInitialText:title];
        
        [composer addImage:image];
        
        [viewController presentViewController:composer animated:YES completion:completion];
    }
}



@end
