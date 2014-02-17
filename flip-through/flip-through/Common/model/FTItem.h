//
//  FTItem.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

@class FTMedia;

@interface FTItem : NSObject
/*
			"title": "Grazalema Village Sierra de Grazalema Andalucía España Spain",
			"link": "http://www.flickr.com/photos/neumeyer/12304161865/",
			"media": {"m":"http://farm8.staticflickr.com/7321/12304161865_20caed8434_m.jpg"},
			"date_taken": "2013-10-29T11:36:09-08:00",
			"description": " <p><a href=\"http://www.flickr.com/people/neumeyer/\">hn.<\/a> posted a photo:<\/p> <p><a href=\"http://www.flickr.com/photos/neumeyer/12304161865/\" title=\"Grazalema Village Sierra de Grazalema Andalucía España Spain\"><img src=\"http://farm8.staticflickr.com/7321/12304161865_20caed8434_m.jpg\" width=\"240\" height=\"180\" alt=\"Grazalema Village Sierra de Grazalema Andalucía España Spain\" /><\/a><\/p> <p>Grazalema Village Sierra de Grazalema Andalucía España Spain Spanien Andalusien Europe Europa EU - (C) Fully copyrighted. No use of any image whatsoever without written royalty agreement. No answer = no permission at all. - (C) Verwendung generell nur nach schriftl. Honorarvereinbg. Keine Antwort = keine Freigabe.<\/p>",
			"published": "2014-02-04T12:59:15Z",
			"author": "nobody@flickr.com (hn.)",
			"author_id": "18068660@N00",
			"tags": ""
*/   

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSArray *media;
@property (nonatomic, copy) NSDate *date_taken;
@property (nonatomic, copy) NSString *description1;
@property (nonatomic, copy) NSDate *published;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *author_id;
@property (nonatomic, copy) NSString *tags;
@property (nonatomic, strong) NSString *lowImageName;
@property (nonatomic, strong) NSString *editedImageName;

- (NSString *)mediaUrl;
- (NSString *)mediaBigUrl;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)serialize;

@end

