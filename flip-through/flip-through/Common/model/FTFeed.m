//
//  FTFeed.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTFeed.h"
#import "FTItem.h"

@implementation FTFeed

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

        _link = [dict objectForKey:@"link"];
        if (!_link)
        {
            return nil;
        }

        _description1 = [dict objectForKey:@"description1"];
        if (!_description1)
        {
            return nil;
        }

        _modified = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"modified"] doubleValue]];
        if (!_modified)
        {
            return nil;
        }

        _generator = [dict objectForKey:@"generator"];
        if (!_generator)
        {
            return nil;
        }

        NSMutableArray* tmpArray = [NSMutableArray array];
        NSArray *itemsArray = [dict objectForKey:@"items"];
        FTAssert([itemsArray isKindOfClass:[NSArray class]] && itemsArray.count);
        for (NSDictionary *dict in itemsArray)
        {
            FTAssert([dict isKindOfClass:[NSDictionary class]]);
            FTItem *item = [[FTItem alloc] initWithDictionary:dict];
            [tmpArray addObject:item];
        }
        _items = [NSArray arrayWithArray:itemsArray];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@", self.objectId, self.title, self.link, self.description1, self.modified, self.generator, self.items];
}


- (NSDictionary *)serialize;
{
    NSDictionary * dictionary = [self dictionaryWithValuesForKeys:@[@"objectId", @"title", @"link", @"description1", @"modified", @"generator", @"items"]];
    FTAssert(dictionary);
    
    NSMutableDictionary* serialized = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    FTAssert(serialized);
    
    [serialized setObject:self.objectId forKey:@"objectId"];
    [serialized setObject:self.title forKey:@"title"];
    [serialized setObject:self.link forKey:@"link"];
    [serialized setObject:self.description1 forKey:@"description1"];
    [serialized setObject:[NSNumber numberWithDouble:[self.modified timeIntervalSince1970]] forKey:@"modified"];
    [serialized setObject:self.generator forKey:@"generator"];
    NSMutableArray *itemArray = [NSMutableArray array];
    for (FTItem *item in self.items)
    {
        NSDictionary *dict = [item serialize];
        [itemArray addObject:dict];
    }
    [serialized setObject:itemArray forKey:@"items"];

    return serialized;

}





@end

