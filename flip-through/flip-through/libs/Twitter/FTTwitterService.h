//
//  FTTwitterService.h
//  FT
//
//  Created by Javier Fuchs on 2/19/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTTwitterService : NSObject

+ (FTTwitterService *)sharedInstance;

- (void)configure;

- (void)post:(UIImage *)image title:(NSString *)title viewController:(UIViewController *)viewController completion:(void (^)())completion;

@end
