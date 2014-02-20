//
//  FTGridViewController.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTGridViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) IBOutlet UIView *footerView;

@property (nonatomic, strong) IBOutlet UIView *toolbarView;

@property (nonatomic, strong) IBOutlet UIButton *folderButton;
@property (nonatomic, strong) IBOutlet UIButton *trashButton;
@property (nonatomic, strong) IBOutlet UIButton *formatButton;
@property (nonatomic, strong) IBOutlet UIButton *firstButton;
@property (nonatomic, strong) IBOutlet UIButton *prefButton;
@property (nonatomic, strong) IBOutlet UIButton *infoButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *lastButton;
@property (nonatomic, strong) IBOutlet UIButton *helpButton;

@end
