//
//  FTFacebookService.m
//  FT
//
//  Created by Javier Fuchs on 2/17/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTFacebookService.h"
#import "FTParseService.h"
#import "FTConfig.h"
#import <FacebookSDK.h>
#import "FTFacebookUser.h"
#import "PFObject.h"
#import "NSError+FT.h"
#import <Social/Social.h>


@interface FTFacebookService ()
@end

@implementation FTFacebookService

+ (FTFacebookService *)sharedInstance
{
    static FTFacebookService *_sharedInstance = nil;
    
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
#ifdef DEBUG
    [FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, nil]];
#endif
}

- (void)request:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error)
        {
            FTFacebookUser *facebookUser = [[FTFacebookUser alloc] initWithDictionary:result user:[[FTParseService sharedInstance] currentUser]];
            [facebookUser.object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                finishBlock(succeeded, error);
            }];
        }
        else
        {
            finishBlock(NO, error);
        }

    }];

}

- (void)handlingInvalidSession:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
    {
        if (!error) 
        {
            // handle successful response
            finishBlock(YES, nil);
            
        }
        else
//        else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"])
        {
            // Since the request failed, we can check if it was due to an invalid session
            finishBlock(NO, error);
        }
    }];
}


- (void)uploadImage:(UIImage *)image finishBlock:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    // funca
    [FBRequestConnection startForUploadPhoto:image completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error)
        {
            finishBlock(NO, error);
            return;
        }
        // get the object ID for the Open Graph object that is now stored in the Object API
        NSString *objectId = [result objectForKey:@"id"];
        NSLog(@"object id: %@", objectId);
        
        finishBlock(YES, nil);
    }];

}

- (void)post:(UIImage *)image title:(NSString *)title viewController:(UIViewController *)viewController completion:(void (^)())completion;
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *composer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
//        fbComposer.completionHandler = ^(SLComposeViewControllerResult result) {
//            wself.facebookButton.enabled = YES;
//            wself.twitterButton.enabled = YES;
//        };
        
        [composer setInitialText:title];
        
        [composer addImage:image];
        
        [viewController presentViewController:composer animated:YES completion:completion];
    }
}


- (void)post:(NSString *)title description:(NSString *)description image:(UIImage *)image url:(NSString *)url finishBlock:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    [FBRequestConnection startForUploadStagingResourceWithImage:image completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error)
        {
            finishBlock(NO, error);
            return;
        }
        // Log the uri of the staged image
        NSLog(@"Successfuly staged image with staged URI: %@", [result objectForKey:@"uri"]);
        
        // instantiate a Facebook Open Graph object
        NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
        
        // specify that this Open Graph object will be posted to Facebook
        object.provisionedForPost = YES;
        
        // for og:title
        object[@"title"] = title;
        
        // for og:type, this corresponds to the Namespace you've set for your app and the object type name
        object[@"type"] = @"flip-through:photo";
        
        // for og:description
        object[@"description"] = description;
        
        // for og:url, we cover how this is used in the "Deep Linking" section below
        object[@"url"] = url;
        
        // for og:image we assign the image that we just staged, using the uri we got as a response
        // the image has to be packed in a dictionary like this:
        object[@"image"] = @[@{@"url": [result objectForKey:@"uri"], @"user_generated" : @"false" }];

        [FBRequestConnection startForPostWithGraphPath:@"me" graphObject:object completionHandler:^(FBRequestConnection *connection,
                                                         id result, NSError *error)
         {
             if (error)
             {
                 finishBlock(NO, error);
                 return;
             }
             // get the object ID for the Open Graph object that is now stored in the Object API
             NSString *objectId = [result objectForKey:@"id"];
             NSLog(@"object id: %@", objectId);
             
             // Further code to post the OG story goes here
             finishBlock(YES, nil);
         }];
    }];
}


+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication withSession:(FBSession *)session;
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:session];
}

+ (void)handleDidBecomeActiveWithSession:(FBSession *)session;
{
    return [FBAppCall handleDidBecomeActiveWithSession:session];
}


@end
