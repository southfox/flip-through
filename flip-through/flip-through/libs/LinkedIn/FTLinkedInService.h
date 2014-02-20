//
//  FTLinkedInService.h
//  FT
//
//  Created by Javier Fuchs on 2/19/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTLinkedInService : NSObject

+ (FTLinkedInService *)sharedInstance;

- (void)configure;

- (void)connect:(void (^)(BOOL succeeded, NSError *error))finishBlock;

@end
