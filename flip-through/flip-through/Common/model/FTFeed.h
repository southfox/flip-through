//
//  FTFeed.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

@interface FTFeed : NSObject

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *description1;
@property (nonatomic, copy) NSDate *modified;
@property (nonatomic, copy) NSString *generator;
@property (nonatomic, copy) NSArray* items;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)serialize;

@end

