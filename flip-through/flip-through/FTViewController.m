//
//  FTViewController.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTViewController.h"
#import "FTCell.h"
#import "FTFlickrPublicFeedService.h"
#import "FTAlert.h"
#import "FTFeed.h"
#import "FTItem.h"
#import "UIView+FT.h"
#import "UIImageView+AFNetworking.h"
#import "FTParseService.h"
#import "Reachability+FT.h"
#import "FTAnalyticsService.h"

static CGPoint kFooterViewVisible;
static CGPoint kFooterViewHidden;

#define kCellWidth 150
#define kCellHeight 150

@interface FTViewController ()
@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic) BOOL isShowingFullScreenImage;
@property (nonatomic) BOOL isShowingFooter;
@property (nonatomic) BOOL isRequestingOffset;
@end

@implementation FTViewController


- (id)init
{
    self = [super initWithNibName:NSStringFromClass([FTViewController class]) bundle:nil];
    if (self) {
        _feeds = [NSMutableArray array];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view makeRoundingCorners:8.0];
    
    self.fullImageContainer.alpha = 0;

    [self addGestureRecognizers];

    [self registerCells];
    
    kFooterViewVisible = kFooterViewHidden = self.footerView.center;
    kFooterViewHidden.y += self.footerView.h;
    self.footerView.center = kFooterViewHidden;
    
    [self hideFooter];
    self.view.userInteractionEnabled = YES;

    [[FTAnalyticsService sharedInstance] logEvent:@"UI" withParameters:@{@"view" : NSStringFromClass([self class]), @"fnc" : [NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]}];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseQueryDidFinished:)
                                                 name:FTParseServiceQueryDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[FTAnalyticsService sharedInstance] logEvent:@"UI" withParameters:@{@"view" : NSStringFromClass([self class]), @"fnc" : [NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]}];

    if ([FTParseService sharedInstance].isUpdating)
    {
        [self.collectionView startSpinnerWithString:@"Updating..." tag:1];
    }
    else
    {
        [self parseQueryDidFinished:nil];
    }

}

#pragma mark - UICollectionView Datasource


- (void)registerCells
{
    UINib *cellNib = [UINib nibWithNibName:[FTCell identifier] bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:[FTCell identifier]];
    [self.collectionView registerClass:[FTCell class] forCellWithReuseIdentifier:[FTCell identifier]];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.feeds.count;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    FTAssert(section < [self.feeds count]);
    FTFeed *feed = self.feeds[section];
    FTAssert([feed isKindOfClass:[FTFeed class]]);
    return feed.items.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTCell *cell = (FTCell *) [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FTCell class]) forIndexPath:indexPath];
    
    FTFeed* feed = self.feeds[indexPath.section];
    FTAssert([feed isKindOfClass:[FTFeed class]]);
    
    FTItem* item = feed.items[indexPath.row];
    FTAssert([item isKindOfClass:[FTItem class]]);
    
    [cell configureWithItem:item];
    return cell;
    
}



#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTCell *cell = (FTCell *) [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

    FTItem *item = cell.item;
    FTAssert([item isKindOfClass:[FTItem class]]);
    
    [self showFullScreenItem:cell.item];
}





- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kCellWidth, kCellHeight);
}



- (void)reloadData
{
    
    [self.collectionView reloadData];
    
    [self hideFooter];

    self.isRequestingOffset = NO;
    
    [self.collectionView flashScrollIndicators];

}


- (void)queryFlickr:(void (^)())successBlock
{
    if (self.isRequestingOffset)
    {
        return;
    }
    self.isRequestingOffset = YES;
    
    __block void(^bSuccessBlock)() = successBlock;
    
    __weak typeof(self) wself = self;
    
    [[FTFlickrPublicFeedService sharedInstance] getAllFeeds:^(NSString *errorMessage) {
        [wself performSelector:@selector(performQuery:) withObject:bSuccessBlock afterDelay:0.5];
        
    } successBlock:^(NSArray *rows) {

        [wself.feeds addObjectsFromArray:rows];
        
        [wself reloadData];
        
        bSuccessBlock();
        
    }];
    
}

- (void)performQuery:(void (^)())successBlock;
{
    self.isRequestingOffset = NO;
    
    [self queryFlickr:successBlock];
}




- (void)addGestureRecognizers;
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFullScreenImage)];
    recognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:recognizer];
}


- (void)showFullScreenItem:(FTItem *)item;
{
    if (self.isShowingFullScreenImage)
    {
        return;
    }
    
    NSString *imageUrl = [item mediaBigUrl];
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    __weak typeof(self) wself = self;
    self.fullImageContainer.alpha = 0;
    [self.fullImage setImageWithURL:url placeholderImage:kImagePlaceholder];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.fullImageContainer.alpha = 1;
    } completion:^(BOOL finished) {
        wself.isShowingFullScreenImage = YES;
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
        wself.fullImageContainer.alpha = 0;
    } completion:^(BOOL finished) {
        wself.isShowingFullScreenImage = NO;
    }];
}

- (IBAction)reload:(id)sender;
{
//    [self queryFlickr];
}


#pragma mark -
#pragma mark - UIScroll
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    int h = scrollView.contentOffset.y + scrollView.h - (self.feeds.count * 4 * kCellHeight + 144);
    if (h >= 0)
    {
        [self showFooter];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    
    if (self.isShowingFooter && !self.isRequestingOffset)
    {
        [self queryFlickr:^{
            
        }];
    }
}

#pragma mark footer

- (void)showFooter {
    
    if (self.isShowingFooter)
    {
        return;
    }
    
    __weak typeof(self) wself = self;
    
    self.isShowingFooter = YES;
    [UIView animateWithDuration:0.3 animations:^{
        wself.footerView.center = kFooterViewHidden;
        wself.footerView.center = kFooterViewVisible;
    } completion:^(BOOL finished) {
    }];
}

- (void)hideFooter
{
    if (!self.isShowingFooter)
    {
        return;
    }
    
    __weak typeof(self) wself = self;
    
    [UIView animateWithDuration:0.3 animations:^{
        wself.footerView.center = kFooterViewVisible;
        wself.footerView.center = kFooterViewHidden;
    } completion:^(BOOL finished) {
        wself.isShowingFooter = NO;
        [wself goToBottom];
    }];
    
}

- (void)goToBottom;
{
    // update the scroll view to the last page
    CGPoint co = self.collectionView.contentOffset;
    co.y += kCellHeight * 2;
    CGRect bounds = self.collectionView.bounds;
    bounds.origin = co;
    [self.collectionView scrollRectToVisible:bounds animated:YES];
}

- (void)parseQueryDidFinished:(NSNotification *)notification
{
    [[FTAnalyticsService sharedInstance] logEvent:@"NOTIF" withParameters:@{@"view" : NSStringFromClass([self class]), @"fnc" : [NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__], @"notification": notification.name}];

    __weak typeof(self) wself = self;
    [self queryFlickr:^{
        [wself.collectionView stopSpinner:1];
        [wself queryFlickr:^{
            FTLog(@"finished the 2 first querys");
        }];
    }];

}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ([Reachability isNetworkAvailable] && [[FTParseService sharedInstance] isUpdating])
    {
        [self.collectionView startSpinnerWithString:@"Updating..." tag:1];
    }
}



@end
