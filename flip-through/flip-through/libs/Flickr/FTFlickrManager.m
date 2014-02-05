//
//  FTFlickrManager.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTFlickrManager.h"
#import "FTFeed.h"
#import "FTItem.h"
#import "FTMedia.h"
#import <RestKit/RestKit.h>

@interface FTFlickrManager()
@end


@implementation FTFlickrManager
{
}

+ (FTFlickrManager *)sharedInstance
{
    static FTFlickrManager *_sharedInstance = nil;
    
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



- (void)setup
{
    NSURL *baseURL = [NSURL URLWithString:@"http://api.flickr.com/services/feeds"];
    RKObjectManager * objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"application/x-javascript"];
    
    RKResponseDescriptor *responseDescriptor = [self configureResponseDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager setRequestSerializationMIMEType:@"text/plain"];
    [objectManager setAcceptHeaderWithMIMEType:@"application/x-javascript"];
    
}



- (void)getAllFeeds:(void (^)(NSString* errorMessage))notFoundBlock
        updateBlock:(void (^)(NSString* updateMessage))updateBlock
       successBlock:(void (^)(NSArray* rows))successBlock;
{
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"json", @"format",
                                 @"1", @"nojsoncallback",
                                 nil];

    __block RKObjectManager * objectManager = [RKObjectManager sharedManager];
    
    updateBlock(@"Searching...");
    [objectManager getObjectsAtPath:@"photos_public.gne" parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        FTLog(@"We object mapped the response with the following result: %@", mappingResult);
        
        if (mappingResult.count)
        {
            successBlock(mappingResult.array);
        }
        else
        {
            notFoundBlock(@"No found any results.");
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        FTLog(@"Error: %@", error);
        
        notFoundBlock(error.localizedDescription);
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
                                                             @"media": @"media",
                                                             @"date_taken": @"date_taken",
                                                             @"description": @"description1",
                                                             @"published": @"published",
                                                             @"author": @"author",
                                                             @"author_id": @"author_id",
                                                             @"tags": @"tags",
                                                             }];


//    // media inside feed
//    RKObjectMapping* mediaMapping = [RKObjectMapping mappingForClass:[FTMedia class]];
//    [mediaMapping addAttributeMappingsFromDictionary:@{
//                                                      @"m": @"m"
//                                                      }];
//    
//    [itemMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"media" toKeyPath:@"media" withMapping:mediaMapping]];
//    

    // items
    [objectMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items" toKeyPath:@"items" withMapping:itemMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:objectMapping method:RKRequestMethodGET pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    return responseDescriptor;
}



@end
