//
//  UIView+FT.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 Javier Fuchs. All rights reserved.
//

@interface UIView (FT)

@property (nonatomic) CGPoint o;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGSize s;
@property (nonatomic) CGFloat w;
@property (nonatomic) CGFloat h;

- (void)updateSpinnerWithString:(NSString *)string tag:(NSInteger)tag;

- (void)stopSpinnerWithString:(NSString *)string tag:(NSInteger)tag;

- (void)stopSpinner:(NSInteger)tag;

- (void)startSpinnerWithString:(NSString *)string tag:(NSInteger)tag;

- (void)makeRoundingCorners:(UIRectCorner)corners corner:(CGFloat)corner;

- (void)makeRoundingCorners:(CGFloat)corner;

- (UIImage *)capture;

@end
