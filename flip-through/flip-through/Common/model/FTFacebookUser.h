//
//  FTFacebookUser.h
//  flip-through
//
//  Created by Javier Fuchs on 2/18/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTPFObject.h"

@class PFObject;
@class PFUser;

@interface FTFacebookUser : FTPFObject

@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *timezone;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *locale;
@property (nonatomic, copy) NSDate *updatedTime;
@property (nonatomic, copy) PFUser *user;

- (id)initWithPFObject:(PFObject *)object;
- (id)initWithDictionary:(NSDictionary *)dictionary user:(PFUser *)user;
- (NSURL *)pictureUrl;

@end
