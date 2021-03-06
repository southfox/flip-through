//
//  FTSerializationService.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FTFeed;

@interface FTSerializationService : NSObject

+ (FTSerializationService *)sharedInstance;

- (void)configure;
- (NSArray *)getAllFeeds;
- (void)createFeed:(FTFeed *)feed;
- (void)saveFeed:(FTFeed *)feed;

@end
