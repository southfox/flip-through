//
//  FTFacebookService.h
//  FT
//
//  Created by Javier Fuchs on 2/17/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBSession;

@interface FTFacebookService : NSObject

+ (FTFacebookService *)sharedInstance;

- (void)configure;

- (void)request:(void (^)(BOOL succeeded, NSError *error))finishBlock;

- (void)uploadImage:(UIImage *)image finishBlock:(void (^)(BOOL succeeded, NSError *error))finishBlock;

- (void)post:(UIImage *)image title:(NSString *)title viewController:(UIViewController *)viewController completion:(void (^)())completion;

- (void)post:(NSString *)title description:(NSString *)description image:(UIImage *)image url:(NSString *)url finishBlock:(void (^)(BOOL succeeded, NSError *error))finishBlock;

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication withSession:(FBSession *)session;

+ (void)handleDidBecomeActiveWithSession:(FBSession *)session;

@end
