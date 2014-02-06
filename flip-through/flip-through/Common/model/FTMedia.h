//
//  FTMedia.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

@interface FTMedia : NSObject
/*
        "media": {"m":"http://farm8.staticflickr.com/7321/12304161865_20caed8434_m.jpg"},
*/   

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *m;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)serialize;
- (NSString *)mediaUrl;
- (NSString *)mediaBigUrl;

@end

