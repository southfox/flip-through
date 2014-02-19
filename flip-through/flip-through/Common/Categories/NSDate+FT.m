//
//  NSDate+FT.h
//  FT
//
//  Created by Javier Fuchs on 1/1/11.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "NSDate+FT.h"

@implementation NSDate (FT)

+ (NSDate *)dateFromJsonString:(NSString *)string
{
    FTAssert(string && [string length] && [string isKindOfClass:[NSString class]])
    ;
    static NSDateFormatter *jsonFormatter;
    if (nil == jsonFormatter)
    {
        jsonFormatter = [[NSDateFormatter alloc] init];
        jsonFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    }
    NSString *dateString = [string stringByReplacingOccurrencesOfString:@"Z" withString:@"+0000"];
    __unused NSDate *date = [jsonFormatter dateFromString:dateString];
    FTAssert(date && [date isKindOfClass:[NSDate class]])
    
    return [jsonFormatter dateFromString:dateString];
}

@end
