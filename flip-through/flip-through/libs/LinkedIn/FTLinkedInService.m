//
//  FTLinkedInService.m
//  FT
//
//  Created by Javier Fuchs on 2/19/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTLinkedInService.h"
#import "FTParseService.h"
#import "FTConfig.h"


@interface FTLinkedInService ()
@end

@implementation FTLinkedInService

+ (FTLinkedInService *)sharedInstance
{
    static FTLinkedInService *_sharedInstance = nil;
    
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
    FTConfig *config = [[FTParseService sharedInstance] config];
    FTAssert(config && [config isKindOfClass:[FTConfig class]]);


}


- (void)connect:(void (^)(BOOL succeeded, NSError *error))finishBlock
{
}



@end
