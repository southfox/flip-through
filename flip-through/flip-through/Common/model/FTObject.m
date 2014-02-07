//
//  FTObject.m
//  flip-through
//
//  Created by Javier Fuchs on 2/7/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTObject.h"

#import <Parse/Parse.h>

@implementation FTObject

- (id)initWithPFObject:(PFObject *)object
{
    self = [super init];
    if (self) {
        _objectId = [object objectId];
        _createdAt = [object createdAt];
        _updatedAt = [object updatedAt];
        _object = object;
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.objectId, self.createdAt, self.updatedAt];
}
@end
