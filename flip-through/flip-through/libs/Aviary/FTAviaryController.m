//
//  FTAviaryController.m
//  FT
//
//  Created by Javier Fuchs on 2/5/14.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTAviaryController.h"
#import "UIView+FT.h"
#import "FTConfig.h"
#import "FTParseService.h"
#import "AFPhotoEditorCustomization.h"

@interface FTAviaryController ()
@property (nonatomic, strong) AFPhotoEditorSession *currentSession;
@property (nonatomic, strong) UIViewController *currentViewController;
@end

@implementation FTAviaryController
{
}

+ (FTAviaryController *)sharedInstance
{
    static FTAviaryController *_sharedInstance = nil;
    
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


- (id)init
{
    self = [super init];
    if (self) {
        
        [AFPhotoEditorCustomization setSupportedIpadOrientations:@[@(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)]];
        
        FTConfig *config = [[FTParseService sharedInstance] config];
        FTAssert(config && [config isKindOfClass:[FTConfig class]]);
        
        [AFPhotoEditorCustomization enableInAppPurchases:[config isAviaryInAppPurchasesEnabled]];
    }
    return self;
}


- (void)editImage:(UIImage *)image inViewController:(UIViewController *)viewController;
{
    _currentViewController = viewController;
    
    [self.currentViewController.view startSpinnerWithString:@"Loading..." tag:1];
    
    // Create photo editor
    AFPhotoEditorController *photoEditor = [[AFPhotoEditorController alloc] initWithImage:image];
    [photoEditor setDelegate:self];
    
    // Present the editor
    [self.currentViewController presentViewController:photoEditor animated:YES completion:nil];
    
    // Capture the editor's session and set a strong property with it so that the session is retained
    __block AFPhotoEditorSession *session = [photoEditor session];
    [self setCurrentSession:session];
    
    
    // Create a context with the maximum output resolution
    AFPhotoEditorContext *context = [session createContextWithImage:image];
    
    __weak typeof(self) wself = self;

    // Request that the context asynchronously replay the session's actions on its image.
    [context render:^(UIImage *result) {
        // `result` will be nil if the image was not modified in the session, or non-nil if the session was closed successfully
        if(result != nil)
        {
            [wself saveHiResImage:result]; // Developer-defined method that saves the high resolution image to disk, perhaps.
            
            
        }
        // Release the session.
        [wself setCurrentSession:nil];
        
        [wself.currentViewController.view stopSpinner:1];
        
    }];
}

#pragma mark photo editor
- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    
    // Handle the result image here and dismiss the editor.
    [self.currentViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    // Handle cancellation here
    [self.currentViewController dismissViewControllerAnimated:YES completion:nil];
    [self.currentViewController.view stopSpinner:1];
}

- (void)saveHiResImage:(UIImage *)image;
{
//    [self.photoAviaryImageView setImage:image];
//    
//    TBAsset *asset = self.assets[self.currentPhotoIndex.row];
//    
//    [image saveToDisk:[asset effectImageName]];
//    asset.effectAppliedValue = [NSNumber numberWithBool:YES];
}

#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (BOOL) shouldAutorotate
{
    return NO;
}



@end
