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

@property (nonatomic, strong) IBOutlet UIView *imageContainerView;
@property (nonatomic, strong) IBOutlet UIView *toolbarView;
@property (nonatomic, strong) IBOutlet UIImageView *fullImage;
@property (nonatomic, strong) IBOutlet UIButton *aviaryButton;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;

- (void)showFullScreenItem:(FTItem *)item;
- (void)updateFullScreenItem:(FTItem *)item option:(UIViewAnimationOptions)option;

- (id)init;
- (void)configureView:(UIViewController *)parentViewController leftBlock:(void (^)())leftBlock rightBlock:(void (^)())rightBlock;

- (IBAction)actionButton:(id)sender;

@end