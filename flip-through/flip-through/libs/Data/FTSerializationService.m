//
//  FTSerializationService.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTSerializationService.h"
#import "FTFeed.h"

#define kJsonFileName [NSString stringWithFormat:@"%@.json", NSStringFromClass([self class])]

@interface FTSerializationService()
@property (nonatomic, strong) NSMutableArray *data;
@end


@implementation FTSerializationService
{
}

+ (FTSerializationService *)sharedInstance
{
    static FTSerializationService *_sharedInstance = nil;
    
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
    NSArray *dataDescriptors = [self load];
    
    _data = [NSMutableArray array];

    for (NSDictionary *myFeedDescriptor in dataDescriptors)
    {
        FTFeed *feed = [[FTFeed alloc] initWithDictionary:myFeedDescriptor];
        FTAssert(feed);
        [_data addObject:feed];
        FTLog(@"feed %@", feed);
    }
}

- (NSArray *)getAllFeeds;
{
    return self.data;
}

- (void)createFeed:(FTFeed *)feed;
{
    FTAssert(feed && [feed isKindOfClass:[FTFeed class]]);
    if (feed)
    {
        [self.data addObject:feed];
    }
}

- (void)saveFeed:(FTFeed *)feed;
{
    FTAssert(feed && [feed isKindOfClass:[FTFeed class]]);
    if (feed)
    {
        BOOL changed = NO;
        NSUInteger feedOrder = -1;
        for (FTFeed *currentFeed in self.data)
        {
            if ([currentFeed.objectId isEqualToString:feed.objectId])
            {
                changed = YES;
                feedOrder = [self.data indexOfObject:currentFeed];
                break;
            }
        }
        if (changed && feedOrder != -1 && feedOrder < self.data.count)
        {
            [self.data replaceObjectAtIndex:feedOrder withObject:feed];
        }
        else
        {
            [self.data addObject:feed];
        }
    }
    [self save];
}


- (NSArray *)load
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [paths objectAtIndex:0];
    NSString* jsonDocument = [documentPath stringByAppendingPathComponent:kJsonFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:jsonDocument]) {
        
        // it's not accessible
        return nil;
    }
    
    NSArray* dataDescriptors = [self loadDocument:jsonDocument];
    
    return dataDescriptors;
}




- (BOOL)save;
{    
    NSError* error = nil;
    
    NSMutableArray* array2Serialize = [NSMutableArray array];
    for (FTFeed* myFeed in self.data)
    {
        NSDictionary* myFeedDictionary = [myFeed serialize];
        FTAssert(myFeedDictionary && [myFeedDictionary isKindOfClass:[NSDictionary class]]);
        [array2Serialize addObject:myFeedDictionary];
    }
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:array2Serialize options:0 error:&error];
    
    assert(error == nil);
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [paths objectAtIndex:0];
    NSString* jsonDocument = [documentPath stringByAppendingPathComponent:kJsonFileName];
    
    BOOL saved = [jsonData writeToFile:jsonDocument options:NSDataWritingAtomic error:&error];
    
    assert(error == nil);
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    return saved;
}


- (NSArray*)loadDocument:(NSString*)path
{
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedAlways error:&error];
    
    assert(data && [data isKindOfClass:[NSData class]]);
    if (!data) {
        return nil;
    }
    
    assert(error == nil);
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return nil;
    }
    
    NSArray* array = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    assert(error == nil);
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return nil;
    }
    
    assert(array && [array isKindOfClass:[NSArray class]]);
    
    return array;
}


@end
