//
//  FTAviaryController.h
//  FT
//
//  Created by Javier Fuchs on 2/5/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFPhotoEditorController.h"

@class FTItem;

@interface FTAviaryController : NSObject <AFPhotoEditorControllerDelegate>

+ (FTAviaryController *)sharedInstance;

- (void)editImage:(UIImage *)image editedImageName:(NSString *)editedImageName inViewController:(UIViewController *)viewController saveBlock:(void (^)(UIImage *image))saveBlock;

@end
