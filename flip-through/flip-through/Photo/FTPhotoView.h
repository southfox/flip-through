//
//  FTPhotoView.h
//  flip-through
//
//  Created by Javier Fuchs on 2/12/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FTItem;

@interface FTPhotoView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *fullImage;

- (void)showFullScreenItem:(FTItem *)item;
- (void)updateFullScreenItem:(FTItem *)item option:(UIViewAnimationOptions)option;

- (id)init;
- (void)configureView:(UIView *)view leftBlock:(void (^)())leftBlock rightBlock:(void (^)())rightBlock;

@end
