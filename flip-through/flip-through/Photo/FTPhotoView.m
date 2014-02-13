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


@interface FTPhotoView ()
@property (nonatomic) BOOL isShowingFullScreenImage;
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

- (void)configureView:(UIView *)view leftBlock:(void (^)())leftBlock rightBlock:(void (^)())rightBlock;
{
    [view addSubview:self];
    _leftBlock = leftBlock;
    _rightBlock = rightBlock;
}

- (void)awakeFromNib
{
    [self makeRoundingCorners:8.0];
    self.alpha = 0;
    [self addGestureRecognizers];
}




- (void)addGestureRecognizers;
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFullScreenImage)];
    recognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:recognizer];
    
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




@end
