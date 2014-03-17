//
//  UIImage+FT.m
//  flip-trough
//
//  Created by Javier Fuchs on 1/1/11.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "UIImage+FT.h"
//#import "NSString+FT.h"
#import "FTAppDelegate.h"

@implementation UIImage (FT)


+ (UIImage *)loadFromDisk:(NSString *)urlString;
{
    static NSString *documentPath = nil;
    if (!documentPath)
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentPath = [paths objectAtIndex:0];
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentPath, urlString];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:fullPath];
        FTAssert(image && [image isKindOfClass:[UIImage class]]);
        return image;
    }
    return nil;
}

+ (void)removeFromDisk:(NSString *)urlString;
{
    static NSString *documentPath = nil;
    if (!documentPath)
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentPath = [paths objectAtIndex:0];
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentPath, urlString];
    
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        if (error)
        {
            FTLog(@"error %@ removing file %@", error, fullPath);
            return;
        }
    }
}


- (void)saveToDisk:(NSString *)urlString;
{
    NSData *data = nil;
    NSString *extension = [urlString pathExtension];
    if ([extension isEqualToString:@"png"])
    {
        data = UIImagePNGRepresentation(self);
    }
    else if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"])
    {
        data = UIImageJPEGRepresentation(self, 1.0);
    }
    else
    {
        FTAssert(NO);
    }
    if (data)
    {
        static NSString *documentPath = nil;
        if (!documentPath)
        {
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            documentPath = [paths objectAtIndex:0];
        }
        
        NSError *writeError = nil;
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentPath, urlString];
        [data writeToFile:fullPath options:NSDataWritingAtomic error:&writeError];
        FTLog(@"saving %@, error %@", urlString, writeError);
    }
}

- (UIImage *)thumbnailBySize:(CGSize)size;
{
    UIImage *originalImage = self;
    UIGraphicsBeginImageContext(size);
    [originalImage drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



@end
