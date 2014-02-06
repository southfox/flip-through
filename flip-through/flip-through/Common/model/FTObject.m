//
//  SCPObject.m
//  SportsChatPlace
//
//  Created by Javier Fuchs on 8/6/13.
//  Copyright (c) 2013 Blue Whale Apps. All rights reserved.
//

#import "SCPObject.h"

#import <Parse/Parse.h>

@implementation SCPObject

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
