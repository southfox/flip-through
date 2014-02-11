Develop an iOS mobile app that will display public photos from flickr™ using objective C. 
http://www.flickr.com/ 

Details:
The app display a collection of small images with pagination and provide the ability to display a larger version of any image once you touch it.

The app launch quickly, remain responsive at all times, is intuitive to use, and it's fully tested.

There are some asynchronous requests and caching so the user can go through pictures without blocking call and with decent speed.
Now it's using the public flickr feed which does not require authentication: http://www.flickr.com/services/feeds/docs/photos_public/

When you start the application it querys 20 items in a feed, parse the information and shows all the 20 pictures in a collection view.
Scrolling vertically a new query is made with the 20 next items.

The application works with RestKit and CocoaPods (it's a library dependency manager, is very good for integrate frameworks in iOS applications).

Services implemented and used:
- Data: implements a good shared resource inside the application to save information locally. It serializes the model data into a json file, and recover the file when the application become active.
- Reachability: to know when there is network available.
- Parse: there's a table with the configuration in parse.com.
- Analytics: it works with flurry, parse log
- Crittercism is the crash framework. Inside Analytics is a good place to leave the crumbs.

TBD:

There are additional functionality such as displaying photos for a particular user or tag or location.
There are third party libraries, but I DON’T use a pre-baked flickr client like ObjectiveFlickr https://github.com/lukhnos/objectiveflickr
In the future I'll add:
- sharing using: mail, facebook, tweet, linkedin, google+, Pinterest, digg, StumbleUpon, Reddit, Tumblr, Adtty, Allvoices, Amazon Wishlist, Arto, Baidu, Bebo, Blinklist, Blip, Blogmarks, Blogger, Brainity, BuddyMarks, Buffer, Add to BX, Care2, chiq, CiteULike, Connotea, coRank, Corcboard, Current, Dealspi.us, Delicius, Digg, Diigo, .net Shoutout, DZone, Edmodo and flickr off course.
- With flickr the use should be restriced to services that doess not require authentication. Now it's using the public flickr feed which does not require authentication: http://www.flickr.com/services/feeds/docs/photos_public/

Settings
Help
My Favorites
Search
Tags


Bug fixing:
I found that the JSON parser is not parsing very well when there are escaped single quotes in a string:
    Fixed bug on JSON parser, does not support escaped single quotes. The problem was inside: 
    +++ b/flip-through/Pods/RestKit/Code/Support/RKNSJSONSerialization.m
    A simple replace of the escaped single quote fixed that for now.
    It's a problem in JSONKit inside RestKit.


