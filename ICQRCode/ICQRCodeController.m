//
//  ICQRCodeController.m
//  ICUIKit
//
//  Created by _ivanC on 3/25/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICQRCodeController.h"

@interface ICQRCodeController () <ICQRCodeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) ICQRCodeViewController *qrCodeViewController;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@end

@implementation ICQRCodeController

#pragma mark - Getters
- (BOOL)isQRCodeViewPresented
{
    return (self.qrCodeViewController != nil);
}

#pragma mark - Public
- (void)presentQRCodeView:(BOOL)animated completion:(void (^)(void))completion
{
    if ([self isQRCodeViewPresented])
    {
        return;
    }
    
    self.qrCodeViewController = [[ICQRCodeViewController alloc] init];
    self.qrCodeViewController.delegate = self;
    
    [self.delegate ICQRCodeController:self willPresentQRCodeView:self.qrCodeViewController.view];
    
    UIViewController *appViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [appViewController presentViewController:self.qrCodeViewController
                                    animated:animated
                                  completion:^{
                                     
                                      [self.qrCodeViewController startScanQRCode];
                                      if (completion)
                                      {
                                          completion();
                                      }
                                  }];
}

- (void)dismissQRCodeView:(BOOL)animated completion:(void (^)(void))completion
{
    if (![self isQRCodeViewPresented])
    {
        return;
    }
    
    [self.qrCodeViewController stopScanQRCode];
    [self.qrCodeViewController dismissViewControllerAnimated:animated
                                                  completion:^{
                                                      
                                                      self.qrCodeViewController.delegate = nil;
                                                      self.qrCodeViewController = nil;
                                                      if (completion)
                                                      {
                                                          completion();
                                                      }
                                                  }];
}

- (void)presentImageGallery:(BOOL)animated;
{
    if (self.imagePickerController)
    {
        return;
    }
    
    [self.qrCodeViewController stopScanQRCode];

    self.imagePickerController = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        self.imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePickerController.sourceType];
        
    }
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = NO;
    [self.qrCodeViewController presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - Encode & Decode
+ (UIImage *)QRCodeImageFromString:(NSString *)inputString
{
    if ([inputString length] <= 0)
    {
        return nil;
    }
    
    NSData *data = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    
    // @"L", @"M", @"Q", @"H"
    //[filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage *outputImage = filter.outputImage;
    UIImage *qrCodeImage = [UIImage imageWithCIImage:outputImage];
    
    return qrCodeImage;
}

+ (NSString *)decodedStringFromQRCodeImage:(UIImage *)qrImage
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 || qrImage == nil)
    {
        return nil;
    }
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
    CIImage *image = [[CIImage alloc] initWithImage:qrImage];
    NSArray *features = [detector featuresInImage:image];
    
    NSString *resultString = nil;
    if ([features count] > 0)
    {
        CIQRCodeFeature *feature = [features firstObject];
        resultString = feature.messageString;
    }
    
    return resultString;
}

#pragma mark - ICQRCodeViewControllerDelegate
- (void)ICQRCodeViewController:(ICQRCodeViewController *)viewController accessDenied:(AVAuthorizationStatus)authorizationStatus
{
    [self.delegate ICQRCodeController:self accessDenied:authorizationStatus];
}

- (void)ICQRCodeViewController:(ICQRCodeViewController *)viewController didFinishScanQRCode:(NSString *)resultString
{
    [self.delegate ICQRCodeVController:self didFinishScanQRCode:resultString];
}

- (void)ICQRCodeViewControllerClose:(ICQRCodeViewController *)viewController
{
    [self dismissQRCodeView:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                                   UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
                                   NSString *resultString = [ICQRCodeController decodedStringFromQRCodeImage:selectedImage];
                                   
                                   if ([resultString length] > 0)
                                   {
                                       [self.delegate ICQRCodeVController:self didFinishScanQRCode:resultString];
                                   }
                                   else
                                   {
                                       [self.delegate ICQRCodeVController:self didFailDecodeFromQRCodeImage:selectedImage];
                                       [self.qrCodeViewController startScanQRCode];
                                   }
                                   
                                   self.imagePickerController.delegate = nil;
                                   self.imagePickerController = nil;
                               }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePickerController dismissViewControllerAnimated:YES
                                                   completion:^{
                                                       
                                                       [self.qrCodeViewController startScanQRCode];

                                                       self.imagePickerController.delegate = nil;
                                                       self.imagePickerController = nil;

                                                   }];
}

@end
