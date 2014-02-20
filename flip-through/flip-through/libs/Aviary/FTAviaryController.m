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
#import "UIImage+FT.h"

@interface FTAviaryController ()
@property (nonatomic, strong) AFPhotoEditorSession *currentSession;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, copy) void (^saveBlock)(UIImage *image);
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


- (void)editImage:(UIImage *)image editedImageName:(NSString *)editedImageName inViewController:(UIViewController *)viewController saveBlock:(void (^)(UIImage *image))saveBlock;
{
    _currentViewController = viewController;
    _saveBlock = saveBlock;
    
    [self.currentViewController.view startSpinnerWithString:@"Loading..." tag:1];
    
    // Create photo editor
    AFPhotoEditorController *photoEditor = [[AFPhotoEditorController alloc] initWithImage:image];
    [photoEditor setDelegate:self];
    
    [self.currentViewController presentViewController:photoEditor animated:NO completion:nil];
    
    // Present the editor
    photoEditor.view.alpha = 0;
    __block AFPhotoEditorController *beditor = photoEditor;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        beditor.view.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
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
    [self closeEditor:editor image:image];
    
    
}


- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    // Handle cancellation here
    [self closeEditor:editor image:nil];
}

- (void)closeEditor:(AFPhotoEditorController *)editor image:(UIImage *)image;
{
    __block AFPhotoEditorController *beditor = editor;
    __block UIImage *bimage = image;
    __weak typeof(self) wself = self;

    [self.currentViewController dismissViewControllerAnimated:NO completion:^{
        beditor.view.alpha = 1;
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            beditor.view.alpha = 0;
        } completion:^(BOOL finished) {
            [wself.currentViewController.view stopSpinner:1];
            wself.saveBlock(bimage);
        }];
    }];

}

- (void)saveHiResImage:(UIImage *)image editedImageName:(NSString *)editedImageName;
{
    [image saveToDisk:editedImageName];
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
