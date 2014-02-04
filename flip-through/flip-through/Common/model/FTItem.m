//
//  FTItem.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTItem.h"
#import "FTMedia.h"

@implementation FTItem

- (id)init
{
    self = [super init];
    if (self) {
        _objectId = [NSString stringWithFormat:@"%@_%lf", NSStringFromClass([self class]), [[NSDate date] timeIntervalSince1970]];
    }
    return self;
}


- (id)initWithDictionary:(NSDictionary *)dict
{
    if ([self init]) {

        _objectId = [dict objectForKey:@"objectId"];
        if (!_objectId)
        {
            return nil;
        }
        
        _title = [dict objectForKey:@"title"];
        if (!_title)
        {
            return nil;
        }
        _media = [[FTMedia alloc] initWithDictionary:[dict objectForKey:@"media"]];
        if (!_media)
        {
            return nil;
        }
        _date_taken = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"date_taken"] doubleValue]];
        _description1 = [dict objectForKey:@"description1"];
        if (!_description1)
        {
            return nil;
        }
        _published = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"published"] doubleValue]];

        _author = [dict objectForKey:@"author"];
        if (!_author)
        {
            return nil;
        }
        _author_id = [dict objectForKey:@"author_id"];
        if (!_author_id)
        {
            return nil;
        }
        _tags = [dict objectForKey:@"tags"];
        if (!_tags)
        {
            return nil;
        }
    }
    return self;
}





- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ %@ %@", self.objectId, self.title, self.media, self.date_taken];
}


- (NSDictionary *)serialize;
{
    NSDictionary * dictionary = [self dictionaryWithValuesForKeys:@[@"objectId", @"title", @"media", @"date_taken", @"description1", @"published", @"author", @"author_id", @"tags"]];
    FTAssert(dictionary);
    
    NSMutableDictionary* serialized = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    FTAssert(serialized);
    
    [serialized setObject:self.objectId forKey:@"objectId"];
    [serialized setObject:self.title forKey:@"title"];
    [serialized setObject:[self.media serialize] forKey:@"media"];
    [serialized setObject:[NSNumber numberWithDouble:[self.date_taken timeIntervalSince1970]] forKey:@"date_taken"];
    [serialized setObject:self.description1 forKey:@"description1"];
    [serialized setObject:[NSNumber numberWithDouble:[self.published timeIntervalSince1970]] forKey:@"published"];
    [serialized setObject:self.author forKey:@"author"];
    [serialized setObject:self.author_id forKey:@"author_id"];
    [serialized setObject:self.tags forKey:@"tags"];

    return serialized;

}

@end