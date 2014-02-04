//
//  FTMedia.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTMedia.h"


@implementation FTMedia

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
        
        _m = [dict objectForKey:@"m"];
        if (!_m)
        {
            return nil;
        }
    }
    return self;
}





- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.objectId, self.m];
}


- (NSDictionary *)serialize;
{
    NSDictionary * dictionary = [self dictionaryWithValuesForKeys:@[@"objectId", @"m"]];
    FTAssert(dictionary);
    
    NSMutableDictionary* serialized = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    FTAssert(serialized);
    
    [serialized setObject:self.objectId forKey:@"objectId"];
    [serialized setObject:self.m forKey:@"m"];

    return serialized;

}

@end
