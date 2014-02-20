//
//  FTMailControler.h
//  FT
//
//  Created by Javier Fuchs on 2/19/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface FTMailControler : NSObject <MFMailComposeViewControllerDelegate>

+ (FTMailControler *)sharedInstance;

- (void)show:(NSString *)subject message:(NSString *)message image:(UIImage *)image viewController:(UIViewController *)viewController completion:(void (^)(void))completion;


@end
