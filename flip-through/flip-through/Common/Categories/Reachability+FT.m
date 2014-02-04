//
//  Reachability+FT.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 Javier Fuchs. All rights reserved.
//

#import "Reachability+FT.h"
#import "Reachability.h"

@implementation Reachability (FT)

+ (BOOL)isNetworkAvailable
{
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

@end
