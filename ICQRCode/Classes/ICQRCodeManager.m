//
//  ICQRCodeManager.m
//  ICUIKit
//
//  Created by _ivanC on 3/25/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICQRCodeManager.h"
#import "ICQRCodeController.h"

@interface ICQRCodeManager () <ICQRCodeControllerDelegate>

@property (nonatomic, strong) ICQRCodeController *qrCodeController;
@property (nonatomic, strong) UIView *extraControlsView;

@end

@implementation ICQRCodeManager

#pragma mark - Lifecycle
+ (instancetype)sharedManager
{
    static ICQRCodeManager *s_instance = nil;
    
    if (s_instance == nil)
    {
        @synchronized(self)
        {
            if (s_instance == nil)
            {
                s_instance = [[self alloc] init];
            }
        }
    }
    
    return s_instance;
}

#pragma mark - Getters
- (ICQRCodeController *)qrCodeController
{
    if (_qrCodeController == nil)
    {
        _qrCodeController = [[ICQRCodeController alloc] init];
        _qrCodeController.delegate = self;
    }
    
    return _qrCodeController;
}

#pragma mark - 
- (void)prepareExtraControls:(UIView *)parentView
{
    if (_extraControlsView == nil)
    {
        _extraControlsView = [[UIView alloc] initWithFrame:parentView.bounds];
        _extraControlsView.backgroundColor = [UIColor clearColor];
        
        CGFloat frameWidth = 250;
        CGFloat buttonWidth = 50;
        UIImageView *scanFrameView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           frameWidth,
                                                                           frameWidth)];
        scanFrameView.center = CGPointMake(CGRectGetMidX(parentView.bounds), CGRectGetMidY(parentView.bounds));
        scanFrameView.layer.borderColor = [[UIColor whiteColor] CGColor];
        scanFrameView.layer.borderWidth = 1;
        [_extraControlsView addSubview:scanFrameView];

        CGFloat gapBetweenButtons = (CGRectGetWidth(_extraControlsView.bounds) - buttonWidth*3)/4;
        UIButton * galleryButton = [[UIButton alloc] initWithFrame:CGRectMake(gapBetweenButtons,
                                                                             CGRectGetMaxY(scanFrameView.frame) + gapBetweenButtons,
                                                                             buttonWidth,
                                                                             buttonWidth)];
        [galleryButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
        [galleryButton setTitle:@"🎑" forState:UIControlStateNormal];
        [galleryButton addTarget:self action:@selector(galleryClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_extraControlsView addSubview:galleryButton];
        
        UIButton *flashLightButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(galleryButton.frame) + gapBetweenButtons,
                                                                                CGRectGetMinY(galleryButton.frame),
                                                                                buttonWidth,
                                                                                buttonWidth)];
        [flashLightButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
        [flashLightButton setTitle:@"🔦" forState:UIControlStateNormal];
        [flashLightButton addTarget:self action:@selector(flashLightClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_extraControlsView addSubview:flashLightButton];
        flashLightButton.enabled = [self.qrCodeController.qrCodeViewController isTorchSupported];

        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(flashLightButton.frame) + gapBetweenButtons,
                                                                           CGRectGetMinY(galleryButton.frame),
                                                                           buttonWidth,
                                                                           buttonWidth)];
        [closeButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
        [closeButton setTitle:@"❌" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_extraControlsView addSubview:closeButton];
    }
}

#pragma mark - Callbacks
- (void)galleryClicked:(id)sender
{
    [self.qrCodeController presentImageGallery:YES];
}

- (void)flashLightClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.qrCodeController.qrCodeViewController setTorchEnabled:sender.selected];
}

- (void)closeClicked:(id)sender
{
    [self.qrCodeController dismissQRCodeView:YES
                                  completion:^{
                                  
                                      self.qrCodeController.delegate = nil;
                                      self.qrCodeController = nil;
                                      
                                      [self.extraControlsView removeFromSuperview];
                                      self.extraControlsView = nil;
                                  }];
}

#pragma mark - Public
- (BOOL)isQRCodeViewPresented
{
    return [_qrCodeController isQRCodeViewPresented];
}

- (void)presentQRCodeView:(BOOL)animated completion:(void (^)(void))completion
{
    [self.qrCodeController presentQRCodeView:animated completion:completion];
}

- (void)dismissQRCodeView:(BOOL)animated completion:(void (^)(void))completion
{
    [self.qrCodeController dismissQRCodeView:animated completion:completion];
}

#pragma mark - ICQRCodeControllerDelegate
- (void)ICQRCodeController:(ICQRCodeController *)controller willPresentQRCodeView:(UIView *)qrCodeView
{
    [self prepareExtraControls:qrCodeView];
    [qrCodeView addSubview:self.extraControlsView];
}

- (void)ICQRCodeController:(ICQRCodeController *)controller accessDenied:(AVAuthorizationStatus)authorizationStatus
{}

- (void)ICQRCodeVController:(ICQRCodeController *)controller didFinishScanQRCode:(NSString *)resultString
{}

- (void)ICQRCodeVController:(ICQRCodeController *)controller didFailDecodeFromQRCodeImage:(UIImage *)qrCodeImage
{}

@end
