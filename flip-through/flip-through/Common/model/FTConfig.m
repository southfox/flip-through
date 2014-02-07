//
//  FTConfig.m
//  flip-through
//
//  Created by Javier Fuchs on 2/7/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTConfig.h"
#import "FTObject.h"
#import <Parse/Parse.h>
#import <RestKit.h>

NSString* kConfigDownloaded = @"kConfigDownloaded";

@implementation FTConfig
{
}


- (id)initWithPFObject:(PFObject *)object
{
    self = [super initWithPFObject:object];
    if (self) {
    }
    return self;
}

- (NSString *)description
{
    return @"";
}



@end
