//
//  FTConfig.h
//  SportsChatPlace
//
//  Created by Javier Fuchs on 8/25/13.
//  Copyright (c) 2013 Blue Whale Apps. All rights reserved.
//

#import "FTObject.h"

@class PFObject;

@interface FTConfig : FTObject

@property (nonatomic, copy) NSString *flickrFeedUrl;
@property (nonatomic, copy) NSString *flickrFeedPath;
@property (nonatomic, copy) NSString *flickrFeedParam;
@property (nonatomic, copy) NSString *aviaryAPIKey;
@property (nonatomic, copy) NSString *facebookAppId;
@property (nonatomic, copy) NSString *flurryAppKey;

- (id)initWithPFObject:(PFObject *)object;

@end
