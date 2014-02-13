//
//  FTGridCell.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTGridCell.h"
#import "UIView+FT.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "FTItem.h"
#import "FTMedia.h"

@interface FTGridCell()
@end

@implementation FTGridCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([FTGridCell class]) owner:self options:nil];
        FTAssert([array count]);
        FTAssert([[array objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]);
        self = [array objectAtIndex:0];
        FTAssert([self isKindOfClass:[FTGridCell class]]);
    }
    
    return self;
    
}


- (void)awakeFromNib
{
    [self makeRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomRight) corner:16.0];
    [self.containerView makeRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomRight) corner:16.0];
}



- (void)layoutSubviews
{
    NSString *imageUrl = [self.item mediaUrl] ;
    NSURL *url = [NSURL URLWithString:imageUrl];
    [self.imageView setImageWithURL:url placeholderImage:kImagePlaceholder];
}



- (void)configureWithItem:(FTItem *)item;
{
    _item = item;
    [self setNeedsLayout];
}


+ (NSString *)identifier;
{
    return NSStringFromClass([FTGridCell class]);
}

@end
