//
//  FTFlickrService.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FTFeed;

@interface FTFlickrService : NSObject

+ (FTFlickrService *)sharedInstance;

- (void)configure;

- (void)getAllFeeds:(void (^)(NSString* errorMessage))notFoundBlock updateBlock:(void (^)(NSString* updateMessage))updateBlock successBlock:(void (^)(NSArray* rows))successBlock;

@end
