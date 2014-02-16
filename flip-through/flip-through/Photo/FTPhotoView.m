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

static CGPoint kToolbarViewVisible;
static CGPoint kToolbarViewHidden;


@interface FTPhotoView ()
@property (nonatomic, strong) UIViewController *parentViewController;
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
    [self addGestureRecognizer:swipeRightRecognizer];
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftAction)];
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:swipeLeftRecognizer];
    
    
}



- (void)showFullScreenItem:(FTItem *)item;
{
    if (self.isShowingFullScreenImage)
    {
        return;
    }
    
    [self showItemMedia:item];

    __weak typeof(self) wself = self;
    self.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.alpha = 1;
    } completion:^(BOOL finished) {
        wself.isShowingFullScreenImage = YES;
    }];
}

- (void)updateFullScreenItem:(FTItem *)item option:(UIViewAnimationOptions)option;
{
    if (!self.isShowingFullScreenImage)
    {
        return;
    }
    
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
    __weak typeof(self) wself = self;

    NSString *imageUrl = [item mediaBigUrl];
    NSURL *url = [NSURL URLWithString:imageUrl];

    [self startSpinnerWithString:@"Downloading..." tag:1];
    [self.fullImage setImageWithURL:url placeholderImage:kBigImagePlaceholder success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
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

    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.alpha = 0;
    } completion:^(BOOL finished) {
        wself.isShowingFullScreenImage = NO;
        [wself hideToolbar];
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
    if (sender == self.aviaryButton)
    {
        [[FTAviaryController sharedInstance] editImage:self.fullImage.image inViewController:self.parentViewController];
    }
    else if (sender == self.closeButton)
    {
        [self dismissFullScreenImage];
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



@end
