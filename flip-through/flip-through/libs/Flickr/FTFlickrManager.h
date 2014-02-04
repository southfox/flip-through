//
//  FTFlickrManager.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FTFeed;

@interface FTFlickrManager : NSObject

+ (FTFlickrManager *)sharedInstance;

- (void)setup;
- (NSArray *)getAllFeeds;

@end
