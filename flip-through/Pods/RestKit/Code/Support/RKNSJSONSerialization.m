//
//  RKNSJSONSerialization.m
//  RestKit
//
//  Created by Blake Watters on 8/31/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RKNSJSONSerialization.h"

@implementation RKNSJSONSerialization

+ (id)objectFromData:(NSData *)data error:(NSError **)error
{
    if (!data)
    {
        NSLog(@"Oops! is null");
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (!object)
    {
        NSLog(@"data = [%@]", [NSString stringWithUTF8String:[data bytes]]);
        NSString* escapedString = [NSString stringWithUTF8String:[data bytes]];
        escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\\'" withString:@" "];
        NSData* data1 = [escapedString dataUsingEncoding:NSUTF8StringEncoding];
        if (!data1)
        {
            return nil;
        }
        id object2 = [NSJSONSerialization JSONObjectWithData:data1 options:0 error:error];
        if (object2)
        {
            return object2;
        }
        return nil;

    }
    return object;
}

+ (NSData *)dataFromObject:(id)object error:(NSError **)error
{
    return [NSJSONSerialization dataWithJSONObject:object options:0 error:error];
}

@end
