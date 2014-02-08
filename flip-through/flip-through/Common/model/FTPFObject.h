//
//  FTPFObject.h
//  flip-through
//
//  Created by Javier Fuchs on 2/7/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;

@interface FTPFObject : NSObject

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSDate *updatedAt;
@property (nonatomic, copy) PFObject *object;

- (id)initWithPFObject:(PFObject *)object;

@end
