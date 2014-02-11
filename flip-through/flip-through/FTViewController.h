//
//  FTViewController.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) IBOutlet UIView *fullImageContainer;
@property (nonatomic, strong) IBOutlet UIImageView *fullImage;

@property (nonatomic, strong) IBOutlet UIView *footerView;

@end
