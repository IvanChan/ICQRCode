//
//  ICQRCodeViewController.h
//  
//
//  Created by _ivanC on 3/25/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ICQRCodeViewControllerDelegate;
@interface ICQRCodeViewController : UIViewController

@property (nonatomic, weak) id<ICQRCodeViewControllerDelegate> delegate;

- (void)startScanQRCode;
- (void)stopScanQRCode;

- (BOOL)isTorchSupported;
- (void)setTorchEnabled:(BOOL)torchEnabled;

- (void)setCaptureFocusMode:(AVCaptureFocusMode)focusMode;

@end

@protocol ICQRCodeViewControllerDelegate <NSObject>

- (void)ICQRCodeViewController:(ICQRCodeViewController *)viewController accessDenied:(AVAuthorizationStatus)authorizationStatus;
- (void)ICQRCodeViewController:(ICQRCodeViewController *)viewController didFinishScanQRCode:(NSString *)resultString;

@end