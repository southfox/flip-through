//
//  FTViewController.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTViewController.h"
#import "FTCell.h"
#import "FTFlickrManager.h"
#import "FTAlert.h"
#import "FTFeed.h"
#import "FTItem.h"
#import "UIView+FT.h"
#import "UIImageView+AFNetworking.h"

static CGPoint kFooterViewVisible;
static CGPoint kFooterViewHidden;

@interface FTViewController ()
@property (nonatomic) BOOL isShowingFullScreenImage;
@property (nonatomic) BOOL isShowingFooter;
@property (nonatomic) BOOL isRequestingOffset;
@end

@implementation FTViewController
{
    NSMutableArray *_feeds;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _feeds = [NSMutableArray array];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.view makeRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) corner:8.0];
    
    self.fullImageContainer.alpha = 0;

    [self addGestureRecognizers];

    [self registerCells];
    
    self.collectionView.scrollEnabled = YES;
    
    
    kFooterViewVisible = kFooterViewHidden = self.footerView.center;
    kFooterViewHidden.y += self.footerView.h;
    self.footerView.center = kFooterViewHidden;
    
    [self hideFooter];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self.view startSpinnerWithString:@"Updating..." tag:1];

    [self queryFlickr];
}

#pragma mark - UICollectionView Datasource


- (void)registerCells
{
    UINib *cellNib = [UINib nibWithNibName:@"FTCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"FTCell"];
    [self.collectionView registerClass:[FTCell class] forCellWithReuseIdentifier:@"FTCell"];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _feeds.count;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    FTAssert(section < [_feeds count]);
    FTFeed *feed = _feeds[section];
    FTAssert([feed isKindOfClass:[FTFeed class]]);

    return feed.items.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTCell *cell = (FTCell *) [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FTCell class]) forIndexPath:indexPath];
    
    FTFeed* feed = _feeds[indexPath.section];
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

//- (void)selectCollageAtIndexPath:(NSIndexPath *)indexPath;
//{
//    _currentCollageIndex = indexPath;
//    FTCell *cell = (FTCell *) [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
//    
//    [cell setSelected:YES];
//    
//    [self.collageView setImage:[UIImage imageNamed:[cell imageName]]];
//    
//    [self reloadData];
//    
//}





- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView)
    {
        return CGSizeMake(150.0, 150.0);
    }
    else
    {
        FTAssert(NO);
    }
    return CGSizeZero;
}



- (void)reloadData
{
    
    [self.collectionView reloadData];
    
    [self hideFooter];

    self.isRequestingOffset = NO;

}

- (void)queryFlickr
{
    self.isRequestingOffset = YES;

    __weak typeof(self) wself = self;
    
    [[FTFlickrManager sharedInstance] getAllFeeds:^(NSString *errorMessage) {
        [wself performSelector:@selector(queryFlickr) withObject:nil afterDelay:0.5];

    } updateBlock:^(NSString *updateMessage) {
        
    } successBlock:^(NSArray *rows) {
        
        [wself.view stopSpinner:1];

        [_feeds addObjectsFromArray:rows];
        
    }];
    
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
    
    NSString *imageUrl = [item mediaUrl];
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
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.fullImageContainer.alpha = 0;
    } completion:^(BOOL finished) {
        wself.isShowingFullScreenImage = NO;
    }];
}

- (IBAction)reload:(id)sender;
{
    [self queryFlickr];
}


#pragma mark -
#pragma mark - UIScroll
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    int total = _feeds.count * 20;
    int h = scrollView.contentOffset.y + scrollView.h - total;
    if (h >= 0) {
        [self showFooter];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    
    if (self.isShowingFooter && !self.isRequestingOffset) {
        [self queryFlickr];
    }
}

#pragma mark footer

- (void)showFooter {
    
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
    __weak typeof(self) wself = self;
    
    [UIView animateWithDuration:0.3 animations:^{
        wself.footerView.center = kFooterViewVisible;
        wself.footerView.center = kFooterViewHidden;
    } completion:^(BOOL finished) {
        wself.isShowingFooter = NO;
    }];
    
}



@end
