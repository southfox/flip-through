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

@interface FTViewController ()
@property (nonatomic) BOOL isShowingFullScreenImage;
@end

@implementation FTViewController
{
    NSArray *_feeds;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.view makeRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) corner:8.0];
    
    self.fullImageContainer.alpha = 0;

    [self addGestureRecognizers];

    [self registerCells];
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
    return 1;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    FTFeed* feed = _feeds[0];
    return feed.items.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTCell *cell = (FTCell *) [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FTCell class]) forIndexPath:indexPath];
    FTFeed* feed = _feeds[0];
    FTItem* item = feed.items[indexPath.row];
    [cell configureWithItem:item];
    return cell;
    
}



#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTCell *cell = (FTCell *) [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

    [self showFullScreenImage:cell.imageView.image];
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
        return CGSizeMake(120.0, 120.0);
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
    
}

- (void)queryFlickr
{
    __weak typeof(self) wself = self;
    
    [[FTFlickrManager sharedInstance] getAllFeeds:^(NSString *errorMessage) {
        [wself performSelector:@selector(queryFlickr) withObject:nil afterDelay:0.5];

    } updateBlock:^(NSString *updateMessage) {
        
    } successBlock:^(NSArray *rows) {
        [wself.view stopSpinner:1];

        _feeds = [NSArray arrayWithArray:rows];
        [wself performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];

    }];
    
}



- (void)addGestureRecognizers;
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFullScreenImage)];
    recognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:recognizer];
}


- (void)showFullScreenImage:(UIImage *)image;
{
    if (self.isShowingFullScreenImage)
    {
        return;
    }
    
    __weak typeof(self) wself = self;
    self.fullImageContainer.alpha = 0;
    self.fullImage.image = image;
    
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
    [self.view startSpinnerWithString:@"Updating..." tag:1];
    [self queryFlickr];
}

@end
