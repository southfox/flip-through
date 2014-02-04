//
//  flip-throughCommon.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 Javier Fuchs. All rights reserved.
//

#ifndef FT_FTCommon_h
#define FT_FTCommon_h

// device screen type

#define DEVICE_IS_IPAD                              ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define DEVICE_IS_IPAD_HD                           (DEVICE_IS_IPAD && ([[UIScreen mainScreen] scale] == 2.0))


#define IOS_7    ([[[UIDevice currentDevice] systemVersion] integerValue] >= 7)


#ifdef DEBUG
#define FTLog(__xx, ...)  NSLog(@"%s(%d): " __xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define FTLog(__xx, ...)  {}
#endif


#ifdef DEBUG
#define FTAssert(condition) {if(!(condition)) FTLog("%@", @"FT assert\n"); assert(condition); };
#else
#define FTAssert(condition) {};
#endif




#endif
