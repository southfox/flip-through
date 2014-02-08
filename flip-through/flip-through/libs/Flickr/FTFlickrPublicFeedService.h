//
//  FTFlickrPublicFeedService.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FTFeed;

@interface FTFlickrPublicFeedService : NSObject

+ (FTFlickrPublicFeedService *)sharedInstance;

- (void)configure;

- (void)getAllFeeds:(void (^)(NSString* errorMessage))errorBlock successBlock:(void (^)(NSArray* rows))successBlock;

@end
