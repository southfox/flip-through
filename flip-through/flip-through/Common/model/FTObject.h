//
//  SCPObject.h
//  SportsChatPlace
//
//  Created by Javier Fuchs on 8/6/13.
//  Copyright (c) 2013 Blue Whale Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;

@interface SCPObject : NSObject

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSDate *updatedAt;
@property (nonatomic, copy) PFObject *object;

- (id)initWithPFObject:(PFObject *)object;

@end
