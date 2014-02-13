//
//  FTCrashService.h
//  FT
//
//  Created by Javier Fuchs on 2/13/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCrashService : NSObject

+ (FTCrashService *)sharedInstance;

- (void)configure;

@end
