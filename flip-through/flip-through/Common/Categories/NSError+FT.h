//
//  NSError+FT.h
//  FT
//
//  Created by Javier Fuchs on 2/7/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (FT)

- (NSString *)facebook;
- (NSString *)parse;
+ (id)errorWithMessage:(NSString *)message;

@end
