//
//  FTConfig.m
//  flip-through
//
//  Created by Javier Fuchs on 2/7/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTConfig.h"
#import "FTPFObject.h"
#import <Parse/Parse.h>
#import <RestKit.h>

@implementation FTConfig
{
}


- (id)initWithPFObject:(PFObject *)object
{
    self = [super initWithPFObject:object];
    if (self) {
        _flickrFeedUrl = [object objectForKey:@"flickrFeedUrl"];
        FTAssert(_flickrFeedUrl);
        _flickrFeedPath = [object objectForKey:@"flickrFeedPath"];
        FTAssert(_flickrFeedPath);
        _flickrFeedParam = [object objectForKey:@"flickrFeedParam"];
        FTAssert(_flickrFeedParam);
        _aviaryAPIKey = [object objectForKey:@"aviaryAPIKey"];
        FTAssert(_aviaryAPIKey);
        _facebookAppId = [object objectForKey:@"facebookAppId"];
        FTAssert(_flickrFeedUrl);
        _flurryAppKey = [object objectForKey:@"flurryAppKey"];
        FTAssert(_flurryAppKey);
        _flurryEnabled = [object objectForKey:@"flurryEnabled"];
        FTAssert(_flurryEnabled);
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@", self.flickrFeedUrl, self.flickrFeedPath, self.flickrFeedParam, self.aviaryAPIKey, self.facebookAppId, self.flurryAppKey, self.flurryEnabled];
}


- (BOOL)isFlurryEnabled;
{
    return [self.flurryEnabled boolValue];
}


@end
