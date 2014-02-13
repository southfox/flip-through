//
//  FTFlickrPublicFeedService.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTFlickrPublicFeedService.h"
#import "FTFeed.h"
#import "FTItem.h"
#import "FTMedia.h"
#import <RestKit/RestKit.h>

#import "FTParseService.h"
#import "FTConfig.h"

#import "FTAnalyticsService.h"

#import "Reachability+FT.h"

@interface FTFlickrPublicFeedService()
@property (nonatomic) BOOL isQueryInProcess;
@end


@implementation FTFlickrPublicFeedService
{
}

+ (FTFlickrPublicFeedService *)sharedInstance
{
    static FTFlickrPublicFeedService *_sharedInstance = nil;
    
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



- (void)configure
{
    FTConfig *config = [[FTParseService sharedInstance] config];
    FTAssert(config);
    
    NSURL *baseURL = [NSURL URLWithString:[config flickrFeedUrl]];
    RKObjectManager * objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"application/x-javascript"];

    RKResponseDescriptor *responseDescriptor = [self configureResponseDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
}



- (void)getAllFeeds:(void (^)(NSString* errorMessage))errorBlock
       successBlock:(void (^)(NSArray* rows))successBlock;
{
    if (self.isQueryInProcess)
    {
        errorBlock(@"another query process");
        return;
    }
    
    if (![Reachability isNetworkAvailable])
    {
        FTLogViewEvent(@"SERVICE", @"status", @"no_network");

        errorBlock(@"no internet");
        return;
    }
    
    self.isQueryInProcess = YES;
    
    FTLogViewEvent(@"SERVICE", @"calling", @"all_feads");

    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"json", @"format",
                                 @"1", @"nojsoncallback",
                                 nil];

    __block RKObjectManager * objectManager = [RKObjectManager sharedManager];
    __block void(^bErrorBlock)(NSString* errorMessage) = errorBlock;
    __block void(^bSuccessBlock)(NSArray* rows) = successBlock;
    
    __weak typeof(self) wself = self;

    FTConfig *config = [[FTParseService sharedInstance] config];
    FTAssert(config);
    
    [objectManager getObjectsAtPath:[config flickrFeedPath] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        FTLog(@"We object mapped the response with the following result: %@", mappingResult);
        
        if (mappingResult.count)
        {
            bSuccessBlock(mappingResult.array);
        }
        else
        {
            bErrorBlock(@"no found any results.");
        }
        wself.isQueryInProcess = NO;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        FTLog(@"Error: %@", error);
        
        FTLogViewEvent(@"SERVICE", @"error", [error description]);
        
        bErrorBlock(error.localizedDescription);
        wself.isQueryInProcess = NO;

    }];
    
}


#pragma mark -
#pragma mark request more info from factual

- (RKResponseDescriptor *)configureResponseDescriptor
{
    /*
     title: "Uploads from everyone",
     link: "http://www.flickr.com/photos/",
     description: "",
     modified: "2014-02-04T19:30:40Z",
     generator: "http://www.flickr.com/",
     */
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[FTFeed class]];
    [objectMapping addAttributeMappingsFromDictionary:@{
                                                        @"title": @"title",
                                                        @"link": @"link",
                                                        @"description": @"description1",
                                                        @"modified": @"modified",
                                                        @"generator": @"generator"
                                                        }];
    
    /*
     title: "",
     link: "http://www.flickr.com/photos/100109421@N08/12308735035/",
     media: {
     m: "http://farm8.staticflickr.com/7374/12308735035_6dcf37f80a_m.jpg"
     },
     date_taken: "2013-11-02T13:21:40-08:00",
     description: " <p><a href="http://www.flickr.com/people/100109421@N08/">greenwoodjeni</a> posted a photo:</p> <p><a href="http://www.flickr.com/photos/100109421@N08/12308735035/" title=""><img src="http://farm8.staticflickr.com/7374/12308735035_6dcf37f80a_m.jpg" width="240" height="135" alt="" /></a></p> ",
     published: "2014-02-04T19:30:40Z",
     author: "nobody@flickr.com (greenwoodjeni)",
     author_id: "100109421@N08",
     tags: "flickrandroidapp:filter=none"
     */
    // Now configure the items mapping inside feed
    RKObjectMapping* itemMapping = [RKObjectMapping mappingForClass:[FTItem class]];
    [itemMapping addAttributeMappingsFromDictionary:@{
                                                             @"title": @"title",
                                                             @"link": @"link",
                                                             @"date_taken": @"date_taken",
                                                             @"description": @"description1",
                                                             @"published": @"published",
                                                             @"author": @"author",
                                                             @"author_id": @"author_id",
                                                             @"tags": @"tags",
                                                             }];


    // media inside feed
    RKObjectMapping* mediaMapping = [RKObjectMapping mappingForClass:[FTMedia class]];
    [mediaMapping addAttributeMappingsFromDictionary:@{
                                                      @"m": @"m"
                                                      }];
    
    [itemMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"media" toKeyPath:@"media" withMapping:mediaMapping]];
    

    // items
    [objectMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items" toKeyPath:@"items" withMapping:itemMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:objectMapping method:RKRequestMethodGET pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    return responseDescriptor;
}



@end
