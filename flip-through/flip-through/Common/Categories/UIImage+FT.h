//
//  UIImage+FT.h
//  tripbook
//
//  Created by Javier Fuchs on 1/1/11.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FT)

+ (UIImage *)loadFromDisk:(NSString *)urlString;
+ (void)removeFromDisk:(NSString *)urlString;
- (void)saveToDisk:(NSString *)urlString;
- (UIImage *)thumbnailBySize:(CGSize)size;


@end
