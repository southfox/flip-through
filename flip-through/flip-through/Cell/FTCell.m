//
//  FTCell.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTCell.h"
#import "UIView+FT.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "FTItem.h"
#import "FTMedia.h"

@interface FTCell()
@end

@implementation FTCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"FTCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    
    return self;
    
}


- (void)awakeFromNib
{
    [self makeRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomRight) corner:16.0];
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
    return NSStringFromClass([FTCell class]);
}

@end
