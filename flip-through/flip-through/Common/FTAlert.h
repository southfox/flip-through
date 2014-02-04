//
//  flip-throughAlert.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 Javier Fuchs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FTAlert : UIAlertView <UIAlertViewDelegate, UITextFieldDelegate>

+ (void)alertWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message leftTitle:(NSString*)leftTitle leftBlock:(void (^)())leftBlock rightTitle:(NSString*)rightTitle rightBlock:(void (^)())rightBlock;

+ (void)alertWithFrame:(CGRect)frame prompt:(NSString *)prompt placeholder:(NSString *)placeholder textBlock:(void (^)(NSString* text))textBlock leftTitle:(NSString*)leftTitle leftBlock:(void (^)())leftBlock rightTitle:(NSString*)rightTitle rightBlock:(void (^)())rightBlock;

+ (void)alertWithFrame:(CGRect)frame prompt:(NSString *)prompt placeholder:(NSString *)placeholder value:(NSString *)value textBlock:(void (^)(NSString* text))textBlock leftTitle:(NSString*)leftTitle leftBlock:(void (^)())leftBlock rightTitle:(NSString*)rightTitle rightBlock:(void (^)())rightBlock;

@end
