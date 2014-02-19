//
//  FTPhotoView.m
//  flip-through
//
//  Created by Javier Fuchs on 2/12/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTPhotoView.h"
#import "FTFlickrPublicFeedService.h"
#import "FTAlert.h"
#import "FTFeed.h"
#import "FTItem.h"
#import "UIView+FT.h"
#import "UIImageView+AFNetworking.h"
#import "FTParseService.h"
#import "Reachability+FT.h"
#import "FTAnalyticsService.h"
#import "FTAviaryController.h"
#import "UIImage+FT.h"
#import "FTFacebookService.h"
#import "NSError+FT.h"
#import <Social/Social.h>

static CGPoint kToolbarViewVisible;
static CGPoint kToolbarViewHidden;


@interface FTPhotoView ()
@property (nonatomic, strong) UIViewController *parentViewController;
@property (nonatomic, strong) FTItem *item;
@property (nonatomic) BOOL isDownloaded;
@property (nonatomic) BOOL isShowingFullScreenImage;
@property (nonatomic) BOOL isShowingToolbar;
@property (nonatomic,copy) void (^leftBlock)();
@property (nonatomic,copy) void (^rightBlock)();
@end

@implementation FTPhotoView


- (id)init;
{
    self = [super init];
    if (self) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([FTPhotoView class]) owner:self options:nil];
        FTAssert([array count]);
        self = [array objectAtIndex:0];
        FTAssert(self && [self isKindOfClass:[FTPhotoView class]]);
    }
    return self;
}

- (void)configureView:(UIViewController *)parentViewController leftBlock:(void (^)())leftBlock rightBlock:(void (^)())rightBlock;
{
    _parentViewController = parentViewController;
    [parentViewController.view addSubview:self];
    _leftBlock = leftBlock;
    _rightBlock = rightBlock;
}

- (void)awakeFromNib
{
    kToolbarViewHidden = kToolbarViewVisible = self.toolbarView.center;
    kToolbarViewHidden.y -= self.toolbarView.h;
    self.toolbarView.center = kToolbarViewHidden;
    
    [self makeRoundingCorners:8.0];
    self.alpha = 0;
    [self addGestureRecognizers];
}




- (void)addGestureRecognizers;
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleToolbar)];
    recognizer.cancelsTouchesInView = NO;
    [self.imageContainerView addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightAction)];
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightRecognizer.cancelsTouchesInView = NO;
    [self.imageContainerView addGestureRecognizer:swipeRightRecognizer];
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftAction)];
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftRecognizer.cancelsTouchesInView = NO;
    [self.imageContainerView addGestureRecognizer:swipeLeftRecognizer];
    
    
}



- (void)showFullScreenItem:(FTItem *)item;
{
    if (self.isShowingFullScreenImage)
    {
        return;
    }
    self.isShowingFullScreenImage = YES;

    
    [self showItemMedia:item];

}

- (void)updateFullScreenItem:(FTItem *)item option:(UIViewAnimationOptions)option;
{
    if (!self.isShowingFullScreenImage)
    {
        return;
    }
    [self toggleToolbar];
    
    __weak typeof(self) wself = self;
    __block FTItem *bitem = item;
    [UIView transitionWithView:self.fullImage
                      duration:0.5
                       options:option
                    animations:^{
                        [wself showItemMedia:bitem];
                    }
                    completion:^(BOOL finished) {
                    }];

}

- (void)showItemMedia:(FTItem *)item;
{
    _item = item;
    
    self.alpha = 1;
    __weak typeof(self) wself = self;

    NSURL *lowImageUrl = [NSURL URLWithString:[self.item mediaUrl]];
    NSURL *imageUrl = [NSURL URLWithString:[self.item mediaBigUrl]];

    [self startSpinnerWithString:@"Downloading..." tag:1];
    [self.fullImage setImageWithURL:lowImageUrl];
    [self.fullImage setImageWithURL:imageUrl placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        wself.fullImage.image = image;
        [wself stopSpinner:1];
        [wself toggleToolbar];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [wself stopSpinner:1];
    }];

}

- (void)dismissFullScreenImage;
{
    if (!self.isShowingFullScreenImage)
    {
        return;
    }

    [self hideToolbar];

    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.alpha = 0;
    } completion:^(BOOL finished) {
        wself.isShowingFullScreenImage = NO;
    }];
}


- (void)rightAction
{
    if (!self.isShowingFullScreenImage)
    {
        return;
    }
    self.rightBlock();
}


- (void)leftAction
{
    if (!self.isShowingFullScreenImage)
    {
        return;
    }
    self.leftBlock();
}



- (IBAction)actionButton:(id)sender;
{
    __weak typeof(self) wself = self;
    if (sender == self.aviaryButton)
    {
        [self toggleToolbar];
        [[FTAviaryController sharedInstance] editImage:self.fullImage.image editedImageName:self.item.editedImageName inViewController:self.parentViewController saveBlock:^(UIImage *image) {
            if (image)
            {
                [image saveToDisk:wself.item.editedImageName];
                wself.fullImage.image = image;
                [wself toggleToolbar];
            }
        }];
    }
    else if (sender == self.closeButton)
    {
        [self dismissFullScreenImage];
    }
    else if (sender == self.facebookButton)
    {
        [self facebookPopover];
    }
    else if (sender == self.twitterButton)
    {
        [self sharePhotoUsingService:SLServiceTypeTwitter];
    }
    else if (sender == self.linkedInButton)
    {
        [self linkedInShare];
    }
    else
    {
        FTAssert(NO);
    }
}

#pragma mark -
#pragma mark toolbar

- (void)toggleToolbar;
{
    if (self.isShowingToolbar)
    {
        [self hideToolbar];
    }
    else
    {
        [self showToolbar];
    }
}

- (void)hideToolbar;
{
    if (!self.isShowingToolbar)
    {
        return;
    }
    __weak typeof(self) wself = self;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.toolbarView.center = kToolbarViewHidden;
    } completion:^(BOOL finished) {
        wself.isShowingToolbar = NO;
    }];
}

- (void)showToolbar;
{
    if (self.isShowingToolbar)
    {
        return;
    }
    __weak typeof(self) wself = self;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.toolbarView.center = kToolbarViewVisible;
    } completion:^(BOOL finished) {
        wself.isShowingToolbar = YES;
    }];
}

- (void)facebookPopover;
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"upload", @"share", nil];
    
    [actionSheet showFromRect:self.facebookButton.frame inView:self.facebookButton animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self uploadPhoto];
    }
    else if (buttonIndex == 1)
    {
        [self sharePhotoUsingService:SLServiceTypeFacebook];
    }
}

- (void)uploadPhoto;
{
    __weak typeof(self) wself = self;
    self.facebookButton.enabled = NO;
    [self startSpinnerWithString:@"Uploading..." tag:1];
    [[FTFacebookService sharedInstance] uploadImage:[self.fullImage.image thumbnailBySize:self.fullImage.image.size] finishBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [wself stopSpinner:1];
        }
        else
        {
            [wself stopSpinnerWithString:[error facebook] tag:1];
        }
        wself.facebookButton.enabled = YES;
    }];
    
    //        [[FTFacebookService sharedInstance] post:@"Image from flickr" description:@"I want to share this image" image:[self.fullImage.image thumbnailBySize:self.fullImage.image.size] url:@"http://www.google.com" finishBlock:^(BOOL succeeded, NSError *error) {
    //        }];
    


}

- (void)sharePhotoUsingService:(NSString *)serviceType;
{
    __weak typeof(self) wself = self;
    
    self.facebookButton.enabled = NO;
    self.twitterButton.enabled = NO;
    self.linkedInButton.enabled = NO;
    
    if ([SLComposeViewController isAvailableForServiceType:serviceType])
    {
        SLComposeViewController *fbComposer = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        
        [fbComposer setInitialText:@"Image from flickr"];
        
        [fbComposer addImage:self.fullImage.image];
        
        [self.parentViewController presentViewController:fbComposer animated:YES completion:^{
            wself.facebookButton.enabled = YES;
            wself.twitterButton.enabled = NO;
            wself.linkedInButton.enabled = NO;
        }];
    }
}

- (void)linkedInShare;
{
}

@end
