//
//  FTGridViewController.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTGridViewController.h"
#import "FTPhotoView.h"
#import "FTGridCell.h"
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

@interface FTGridViewController ()
@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic, strong) FTPhotoView *photoView;
@property (nonatomic) BOOL isShowingFooter;
@property (nonatomic) BOOL isRequestingOffset;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@end

@implementation FTGridViewController


- (id)init
{
    self = [super initWithNibName:NSStringFromClass([FTGridViewController class]) bundle:nil];
    if (self) {
        _feeds = [NSMutableArray array];
        _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        _photoView = [[FTPhotoView alloc] init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view makeRoundingCorners:8.0];
    
    [self configurePhotoView];
    
    [self configureCells];
    
    [self configureFooter];
    
    [self configureObservers];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    FTLogViewEvent(@"memory", @"warning", @"here");
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([FTParseService sharedInstance].isUpdating || ![[FTParseService sharedInstance] config])
    {
        [self.collectionView startSpinnerWithString:@"Updating..." tag:1];
    }
    else
    {
        [self parseQueryDidFinished:nil];
    }

}

- (void)configurePhotoView;
{
    __weak typeof(self) wself = self;
    [self.photoView configureView:self leftBlock:^{
        [wself leftAction];
    } rightBlock:^{
        [wself rightAction];
    }];
}

#pragma mark - UICollectionView Datasource


- (void)configureCells
{
    UINib *cellNib = [UINib nibWithNibName:[FTGridCell identifier] bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:[FTGridCell identifier]];
    [self.collectionView registerClass:[FTGridCell class] forCellWithReuseIdentifier:[FTGridCell identifier]];
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
    FTGridCell *cell = (FTGridCell *) [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FTGridCell class]) forIndexPath:indexPath];
    
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
    _currentIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    
    FTLog(@"%d,%d", _currentIndexPath.section, _currentIndexPath.row);
    [self showFullScreen:indexPath];
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







- (void)updateFullScreenOfCurrentIndexPath:(UIViewAnimationOptions)option;
{
    FTGridCell *cell = (FTGridCell *) [self collectionView:self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    
    FTItem *item = cell.item;
    FTAssert([item isKindOfClass:[FTItem class]]);
    
    [self.photoView updateFullScreenItem:cell.item option:option];
}


- (void)showFullScreen:(NSIndexPath *)indexPath;
{
    FTGridCell *cell = (FTGridCell *) [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

    FTItem *item = cell.item;
    FTAssert([item isKindOfClass:[FTItem class]]);

    [self.photoView showFullScreenItem:item];
}




- (void)rightAction
{
    int section = self.currentIndexPath.section - 1;
    int row = self.currentIndexPath.row - 1;
    if (row >= 0)
    {
        _currentIndexPath = [NSIndexPath indexPathForRow:row inSection:self.currentIndexPath.section];
        FTLog(@"%d,%d", _currentIndexPath.section, _currentIndexPath.row);
        
        [self updateFullScreenOfCurrentIndexPath:UIViewAnimationOptionTransitionCurlDown];
    }
    else if (section >= 0)
    {
        _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        FTLog(@"%d,%d", _currentIndexPath.section, _currentIndexPath.row);
        
        [self updateFullScreenOfCurrentIndexPath:UIViewAnimationOptionTransitionCurlDown];
    }
}


- (void)leftAction
{
    int section = self.currentIndexPath.section + 1;
    int row = self.currentIndexPath.row + 1;
    if (row > 0 && row < 20)
    {
        _currentIndexPath = [NSIndexPath indexPathForRow:row inSection:self.currentIndexPath.section];
        FTLog(@"%d,%d", _currentIndexPath.section, _currentIndexPath.row);
        [self updateFullScreenOfCurrentIndexPath:UIViewAnimationOptionTransitionCurlUp];

    }
    else if (section < [self.collectionView numberOfSections])
    {
        _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        FTLog(@"%d,%d", _currentIndexPath.section, _currentIndexPath.row);
        [self updateFullScreenOfCurrentIndexPath:UIViewAnimationOptionTransitionCurlUp];

    }
    else
    {
        __weak typeof(self) wself = self;
        __block int bsection = section;
        [self showFooter:^{
            wself.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:bsection];
            FTLog(@"%d,%d", wself.currentIndexPath.section, wself.currentIndexPath.row);
            [wself updateFullScreenOfCurrentIndexPath:UIViewAnimationOptionTransitionCurlUp];
        }];
    }

}



#pragma mark -
#pragma mark - UIScroll
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    int h = scrollView.contentOffset.y + scrollView.h - (self.feeds.count * 4 * kCellHeight + 144);
    if (h >= 0)
    {
        [self showFooter:^{
            
        }];
    }
}


#pragma mark footer

- (void)configureFooter;
{
    kFooterViewVisible = kFooterViewHidden = self.footerView.center;
    kFooterViewHidden.y += self.footerView.h;
    self.footerView.center = kFooterViewHidden;
    
    [self hideFooter];
    self.view.userInteractionEnabled = YES;
}
- (void)showFooter:(void (^)())completion {
    
    if (self.isShowingFooter)
    {
        return;
    }
    
    __weak typeof(self) wself = self;
    
    __block void(^bCompletion)() = completion;

    self.isShowingFooter = YES;
    [UIView animateWithDuration:0.3 animations:^{
        wself.footerView.center = kFooterViewHidden;
        wself.footerView.center = kFooterViewVisible;
    } completion:^(BOOL finished) {
        [wself queryFlickr:^{
            bCompletion();
        }];
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
    co.y += kCellHeight * 4;
    CGSize s = self.collectionView.s;
    s.width -= 20;
    CGRect bounds;
    bounds.origin = co;
    bounds.size = s;
    [self.collectionView scrollRectToVisible:bounds animated:YES];
}

- (void)parseQueryDidFinished:(NSNotification *)notification
{
    if (notification)
    {
        FTLogViewEvent(@"UI", @"notification", notification.name);
    }

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


- (void)configureObservers;
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseQueryDidFinished:)
                                                 name:FTParseServiceQueryDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
}
@end
