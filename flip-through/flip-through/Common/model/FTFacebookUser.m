//
//  FTFacebookUser.m
//  flip-through
//
//  Created by Javier Fuchs on 2/18/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTFacebookUser.h"
#import "FTPFObject.h"
#import <Parse/Parse.h>
#import <RestKit.h>
#import "NSDate+FT.h"

@implementation FTFacebookUser
{
}


- (id)initWithPFObject:(PFObject *)object;
{
    self = [super initWithPFObject:object];
    if (self) {
        _facebookId = [object objectForKey:@"facebookId"];
        FTAssert(_facebookId);
        _name = [object objectForKey:@"name"];
        FTAssert(_name);
        _timezone = [object objectForKey:@"timezone"];
        FTAssert(_timezone);
        _gender = [object objectForKey:@"gender"];
        FTAssert(_gender);
        _birthday = [object objectForKey:@"birthday"];
        FTAssert(_birthday);
        _email = [object objectForKey:@"email"];
        FTAssert(_email);
        _first_name = [object objectForKey:@"first_name"];
        FTAssert(_first_name);
        _last_name = [object objectForKey:@"last_name"];
        FTAssert(_last_name);
        _link = [object objectForKey:@"link"];
        FTAssert(_link);
        _locale = [object objectForKey:@"locale"];
        FTAssert(_locale);
        _updatedTime = [object objectForKey:@"updated_time"];
        FTAssert(_updatedTime);
        _user = [object objectForKey:@"user"];
        FTAssert(_user);
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary user:(PFUser *)user;
{
    PFObject *object = [PFObject objectWithClassName:@"ft_facebook_user"];
    [object setObject:dictionary[@"id"] forKey:@"facebookId"];
    [object setObject:dictionary[@"name"] forKey:@"name"];
    [object setObject:dictionary[@"timezone"] forKey:@"timezone"];
    [object setObject:dictionary[@"gender"] forKey:@"gender"];
    [object setObject:dictionary[@"birthday"] forKey:@"birthday"];
    [object setObject:dictionary[@"email"] forKey:@"email"];
    [object setObject:dictionary[@"first_name"] forKey:@"first_name"];
    [object setObject:dictionary[@"last_name"] forKey:@"last_name"];
    [object setObject:dictionary[@"link"] forKey:@"link"];
    [object setObject:dictionary[@"locale"] forKey:@"locale"];
    [object setObject:dictionary[@"updated_time"] forKey:@"updated_time"];
    [object setObject:user forKey:@"user"];

    return [self initWithPFObject:object];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@", self.facebookId, self.name, self.timezone, self.gender, self.birthday, self.updatedTime];
}


- (NSURL *)pictureUrl;
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", self.facebookId]];
}


@end

