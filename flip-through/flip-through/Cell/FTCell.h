//
//  FTCell.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FTItem;


@interface FTCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView *imageView;


- (void)configureWithItem:(FTItem *)item;


@end
