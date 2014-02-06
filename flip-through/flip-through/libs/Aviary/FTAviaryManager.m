//
//  FTAviaryManager.m
//  FT
//
//  Created by Javier Fuchs on 2/5/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTAviaryManager.h"

@interface FTAviaryManager ()
@end

@implementation FTAviaryManager
{
}

+ (FTAviaryManager *)sharedInstance
{
    static FTAviaryManager *_sharedInstance = nil;
    
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


- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}




@end
