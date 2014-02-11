//
//  UIView+FT.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 Javier Fuchs. All rights reserved.
//

#import "UIView+FT.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

static const NSInteger kUIViewFTContainerTag = 271828;
static const NSInteger kUIViewFTMessageTag = 111;
static const NSInteger kUIViewFTSpinnerTag = 222;
static const CGRect kUIViewFTMessageFrame = {20.0, 0.0, 200, 100};
static const CGSize kUIViewFTContainerSize = {240.0, 124};
static const CGRect kUIViewFTSpinnerFrame = {100.0, 76.0, 40.0, 40.0};

@implementation UIView (FT)

- (CGPoint)o
{
    return self.frame.origin;
}

- (void)setO:(CGPoint)o
{
    CGRect frame = self.frame;
    frame.origin = o;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void) setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}


- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


- (CGSize)s
{
    return self.frame.size;
}

- (void)setS:(CGSize)s
{
    CGRect frame = self.frame;
    frame.size = s;
    self.frame = frame;
}

- (CGFloat)w
{
    return self.frame.size.width;
}

- (void) setW:(CGFloat)w
{
    CGRect frame = self.frame;
    frame.size.width = w;
    self.frame = frame;
}

- (CGFloat)h
{
    return self.frame.size.height;
}

- (void) setH:(CGFloat)h
{
    CGRect frame = self.frame;
    frame.size.height = h;
    self.frame = frame;
}


- (void)updateSpinnerWithString:(NSString *)string tag:(NSInteger)tag
{
    UIView *subView = [self viewWithTag:kUIViewFTContainerTag + tag];
    
    if (subView)
    {
        UILabel *textLabel = (UILabel *) [subView viewWithTag:kUIViewFTMessageTag];
        textLabel.text = string;
    }
}


- (void)stopSpinnerWithString:(NSString *)string tag:(NSInteger)tag
{
    self.userInteractionEnabled = YES;
    UIView *subView = [self viewWithTag:kUIViewFTContainerTag + tag];

    if (subView)
    {
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *) [subView viewWithTag:kUIViewFTSpinnerTag];
        [spinner stopAnimating];

        UILabel *textLabel = (UILabel *) [subView viewWithTag:kUIViewFTMessageTag];
        textLabel.text = string;
    }

    [NSTimer scheduledTimerWithTimeInterval:2.5 target:subView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
}


- (void)stopSpinner:(NSInteger)tag
{
    self.userInteractionEnabled = YES;
    [[self viewWithTag:kUIViewFTContainerTag+tag] removeFromSuperview];
}


- (void)startSpinnerWithString:(NSString *)string tag:(NSInteger)tag
{
    [self stopSpinner:tag];

    self.userInteractionEnabled = NO;

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kUIViewFTContainerSize.width, kUIViewFTContainerSize.height)];
    containerView.x = self.w/2 - containerView.w/2;
    containerView.y = self.h/2 - containerView.h/2;
    [containerView makeRoundingCorners:6.0];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    containerView.tag = kUIViewFTContainerTag + tag;
    containerView.backgroundColor = [UIColor darkGrayColor];

    if (string)
    {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:kUIViewFTMessageFrame];
        textLabel.tag = kUIViewFTMessageTag;
        textLabel.text = string;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.adjustsFontSizeToFitWidth = YES;
        textLabel.minimumScaleFactor = 0.5;
        textLabel.numberOfLines = 2;
        [containerView addSubview:textLabel];
    }
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = kUIViewFTSpinnerFrame;
    [spinner startAnimating];
    spinner.tag = kUIViewFTSpinnerTag;

    [containerView addSubview:spinner];
    [self addSubview:containerView];
}

- (void)makeRoundingCorners:(UIRectCorner)corners corner:(CGFloat)corner
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(corner, corner)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)makeRoundingCorners:(CGFloat)corner
{
    self.layer.cornerRadius = corner;
    self.layer.masksToBounds = YES;
}


- (UIImage *)capture
{
	UIGraphicsBeginImageContext(self.frame.size);

	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

    return image;
}


@end
