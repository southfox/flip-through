//
//  FTConfig.m
//  SportsChatPlace
//
//  Created by Javier Fuchs on 8/25/13.
//  Copyright (c) 2013 Blue Whale Apps. All rights reserved.
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
}



@end
