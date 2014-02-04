CircleBack 

App Exercise


High level scope:     
Develop an iOS mobile app that will display public photos from flickr™ using objective C. 
http://www.flickr.com/ 

Details:
The app should display a collection of small images with pagination and provide the ability to display a larger version of any image once you touch it.
    1 h.

The app should launch quickly, remain responsive at all times, be intuitive to use, and should be fully tested.
    .5 h.

You might want to include additional functionality such as displaying photos for a particular user or tag or location and maybe do some asynchronous requests and caching so the user can go through pictures without blocking call and with decent speed, but make sure anything you deliver is fully polished.
    2 h.

Feel free to include third party libraries, but DON’T use a pre-baked flickr client like ObjectiveFlickr https://github.com/lukhnos/objectiveflickr

Goals:
The point of this exercise is to show us a little bit of your own code written the way that you think an app should be written. We also want to see how do you deal with webservices and MVC architecture.

You should use the public flickr feed which does not require authentication: http://www.flickr.com/services/feeds/docs/photos_public/
    3 h
        parsing
        model data



Deliverables:
Stick your code up on Github and point me to the repo when you're ready. When you give me the word I'll expect to be able to clone your repo, hit "Run" in the recommended IDE and have it running on a device, website or desktop.

Good luck!


--------------------------------------------------------------------------------
Looking for cars & format is json
    http://api.flickr.com/services/feeds/photos_public.gne?tags=cars&format=json&nojsoncallback=1

    http://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1#

Example:
			"title": "000DC5D81A42(Front Door) motion alarm at 20140204055903",
			"link": "http://www.flickr.com/photos/33523016@N02/12304756856/",
			"media": {"m":"http://farm4.staticflickr.com/3687/12304756856_eae15c1bf5_m.jpg"},
			"date_taken": "2014-02-04T04:59:22-08:00",
			"description": " <p><a href=\"http://www.flickr.com/people/33523016@N02/\">wdlojai<\/a> posted a photo:<\/p> <p><a href=\"http://www.flickr.com/photos/33523016@N02/12304756856/\" title=\"000DC5D81A42(Front Door) motion alarm at 20140204055903\"><img src=\"http://farm4.staticflickr.com/3687/12304756856_eae15c1bf5_m.jpg\" width=\"240\" height=\"180\" alt=\"000DC5D81A42(Front Door) motion alarm at 20140204055903\" /><\/a><\/p> ",
			"published": "2014-02-04T12:59:22Z",
			"author": "nobody@flickr.com (wdlojai)",
			"author_id": "33523016@N02",
			"tags": "front porch"
    
Items model:
title               title
link                linkUrl
media               mediaUrl
date_taken          dateTaken
description         htmlDescription
published           publishedAt
author              author
author_id           author
tags                tags
