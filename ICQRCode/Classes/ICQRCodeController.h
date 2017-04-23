//
//  ICQRCodeController.h
//  ICUIKit
//
//  Created by _ivanC on 3/25/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ICQRCodeViewController.h"

@protocol ICQRCodeControllerDelegate;
@interface ICQRCodeController : NSObject

@property (nonatomic, weak) id<ICQRCodeControllerDelegate> delegate;
@property (nonatomic, strong, readonly) ICQRCodeViewController *qrCodeViewController;

- (BOOL)isQRCodeViewPresented;
- (void)presentQRCodeView:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissQRCodeView:(BOOL)animated completion:(void (^)(void))completion;

- (void)presentImageGallery:(BOOL)animated;

+ (UIImage *)QRCodeImageFromString:(NSString *)inputString;
+ (NSString *)decodedStringFromQRCodeImage:(UIImage *)qrImage;

@end

@protocol ICQRCodeControllerDelegate <NSObject>

- (void)ICQRCodeController:(ICQRCodeController *)controller willPresentQRCodeView:(UIView *)qrCodeView;

- (void)ICQRCodeController:(ICQRCodeController *)controller accessDenied:(AVAuthorizationStatus)authorizationStatus;
- (void)ICQRCodeVController:(ICQRCodeController *)controller didFinishScanQRCode:(NSString *)resultString;
- (void)ICQRCodeVController:(ICQRCodeController *)controller didFailDecodeFromQRCodeImage:(UIImage *)qrCodeImage;

@end
