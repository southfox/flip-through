//
//  FTMailControler.m
//  FT
//
//  Created by Javier Fuchs on 2/19/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTMailControler.h"
#import "FTAlert.h"


@implementation FTMailControler


+ (FTMailControler *)sharedInstance
{
    static FTMailControler *_sharedInstance = nil;
    
    @synchronized (self)
    {
        if (_sharedInstance == nil)
        {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    FTAssert(_sharedInstance != nil);
    
    return _sharedInstance;
}



- (void)show:(NSString *)subject message:(NSString *)message image:(UIImage *)image viewController:(UIViewController *)viewController completion:(void (^)(void))completion;
{
    
    if (![MFMailComposeViewController canSendMail])
    {
        [FTAlert alertWithFrame:viewController.view.frame title:@"Epaaa!" message:@"Please set up the device for sending email" leftTitle:@"Ok" leftBlock:^{} rightTitle:nil rightBlock:nil];
        return;
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:subject];
    
    if (image)
    {
        NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
        [picker addAttachmentData:imgData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"%@.%@", @"flip-through", kCommonImageExtension]];
    }
	   
	[picker setMessageBody:message isHTML:NO];
    
	[viewController presentViewController:picker animated:YES completion:completion];
}





@end