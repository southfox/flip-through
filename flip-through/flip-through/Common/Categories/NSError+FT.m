//
//  NSError+FT.m
//  FT
//
//  Created by Javier Fuchs on 2/7/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "NSError+FT.h"
#import <Parse/PFConstants.h>
#import <FBError.h>

#import "FTParseService.h"

@implementation NSError (FT)

- (NSString *)facebook;
{
    return self.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"message"];
}

- (NSString *)parse;
{
    switch (self.code) {
    case   1:   return @"Internal server error. No information available. ";	break;
    case 100:   return @"The connection to the Parse servers failed. ";	break;
    case 101:   return @"Object doesn't exist, or has an incorrect password. ";	break;
    case 102:   return @"You tried to find values matching a datatype that doesn't support exact database matching, like an array or a dictionary. ";	break;
    case 103:   return @"Missing or invalid classname. Classnames are case-sensitive. They must start with a letter, and a-zA-Z0-9_ are the only valid characters. ";	break;
    case 104:   return @"Missing object id. ";	break;
    case 105:   return @"Invalid key name. Keys are case-sensitive. They must start with a letter, and a-zA-Z0-9_ are the only valid characters. ";	break;
    case 106:   return @"Malformed pointer. Pointers must be arrays of a classname and an object id. ";	break;
    case 107:   return @"Malformed json object. A json dictionary is expected. ";	break;
    case 108:   return @"Tried to access a feature only available internally. ";	break;
    case 111:   return @"Field set to incorrect type. ";	break;
    case 112:   return @"Invalid channel name. A channel name is either an empty string (the broadcast channel) or contains only a-zA-Z0-9_ characters and starts with a letter. ";	break;
    case 114:   return @"Invalid device token. ";	break;
    case 115:   return @"Push is misconfigured. See details to find out how. ";	break;
    case 116:   return @"The object is too large. ";	break;
    case 119:   return @"That operation isn't allowed for clients. ";	break;
    case 120:   return @"The results were not found in the cache. ";	break;
    case 121:   return @"Keys in NSDictionary values may not include '$' or '.'. ";	break;
    case 122:   return @"Invalid file name. A file name contains only a-zA-Z0-9_. characters and is between 1 and 36 characters. ";	break;
    case 123:   return @"Invalid ACL. An ACL with an invalid format was saved. This should not happen if you use PFACL. ";	break;
    case 124:   return @"The request timed out on the server. Typically this indicates the request is too expensive. ";	break;
    case 125:   return @"The email address was invalid. ";	break;
    case 137:   return @"A unique field was given a value that is already taken. ";	break;
    case 139:   return @"Role's name is invalid. ";	break;
    case 140:   return @"Exceeded an application quota.  Upgrade to resolve. ";	break;
    // case 141:   return [self.userInfo objectForKey:@"error"];	break;
    case 142:   return @"Cloud Code validation failed. ";	break;
    case 143:   return @"Product purchase receipt is missing ";	break;
    case 144:   return @"Product purchase receipt is invalid ";	break;
    case 145:   return @"Payment is disabled on this device ";	break;
    case 146:   return @"The product identifier is invalid ";	break;
    case 147:   return @"The product is not found in the App Store ";	break;
    case 148:   return @"The Apple server response is not valid ";	break;
    case 149:   return @"Product fails to download due to file system error ";	break;
    case 150:   return @"Fail to convert data to image. ";	break;
    case 151:   return @"Unsaved file. ";	break;
    case 153:   return @"Fail to delete file. ";	break;
    case 200:   return @"Username is missing or empty ";	break;
    case 201:   return @"Password is missing or empty ";	break;
    case 202:   return @"Username has already been taken ";	break;
    case 203:   return @"Email has already been taken ";	break;
    case 204:   return @"The email is missing, and must be specified ";	break;
    case 205:   return @"A user with the specified email was not found ";	break;
    case 206:   return @"The user cannot be altered by a client without the session. ";	break;
    case 207:   return @"Users can only be created through sign up ";	break;
//    case 208:   return @"An existing Facebook account already linked to another user. ";	break;
    case 208:   return @"An existing account already linked to another user. ";	break;
    case 209:   return @"User ID mismatch ";	break;
//    case 250:   return @"Facebook id missing from request ";	break;
    case 250:   return @"Linked id missing from request ";	break;
//    case 251:   return @"Invalid Facebook session ";	break;
    case 251:   return @"Invalid linked session ";	break;

    }
    id errorStr = [self.userInfo objectForKey:@"error"];
    if (errorStr && [errorStr isKindOfClass:[NSString class]])
    {
        return errorStr;
    }
    NSString *localizedDescription = [self localizedDescription];
    if (localizedDescription)
    {
        return localizedDescription;
    }

    return @"We've encountered a problem connecting to the server. Please try again.";
}


+ (id)errorWithMessage:(NSString *)message;
{
    return [NSError errorWithDomain:@"com.flip.through" code:-1 userInfo:@{@"inner_error_object" : message}];
}

@end
