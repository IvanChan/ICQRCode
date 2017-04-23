//
//  ICQRCodeViewController.m
//  
//
//  Created by _ivanC on 3/25/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICQRCodeViewController.h"

@interface ICQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice  *captureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureDeviceOutput;
@property (nonatomic, strong) AVCaptureSession *captureDeviceSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;

@property (nonatomic, strong) UIView *bgMaskView;

@end

@implementation ICQRCodeViewController

#pragma mark - Lifecycle
- (void)dealloc
{
    [self stopScanQRCode];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.bgMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.bgMaskView.userInteractionEnabled = NO;
    self.bgMaskView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.bgMaskView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapGestureRecognized:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self manaulFocus];
    }
}

#pragma mark - Getters
- (BOOL)isTorchSupported
{
    return ([self.captureDevice hasTorch] && [self.captureDevice hasFlash]);
}

#pragma mark - Setters
- (void)setTorchEnabled:(BOOL)torchEnabled
{
    if ([self.captureDevice hasTorch] && [self.captureDevice hasFlash])
    {
        if ([self.captureDevice lockForConfiguration:nil])
        {
            if (torchEnabled)
            {
                [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
                [self.captureDevice setFlashMode:AVCaptureFlashModeOn];
            }
            else
            {
                [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
                [self.captureDevice setFlashMode:AVCaptureFlashModeOff];
            }
            [self.captureDevice unlockForConfiguration];
        }
    }
}

- (void)setCaptureFocusMode:(AVCaptureFocusMode)focusMode
{
    if ([self.captureDevice lockForConfiguration:nil] && [self.captureDevice isFocusModeSupported:focusMode])
    {
        [self.captureDevice setFocusMode:focusMode];
        [self.captureDevice unlockForConfiguration];
    }
}

#pragma mark - Authorization
- (void)requestAccessForQRScan
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (granted)
            {
                [self _startScanQRCode];
            }
            else
            {
                AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                [self.delegate ICQRCodeViewController:self accessDenied:authorizationStatus];
            }
            
        });

    }];
}

#pragma mark - Focus
- (void)manaulFocus
{
    NSError *error = nil;
    if ([self.captureDevice lockForConfiguration:&error] )
    {
        if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        {
            [self.captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.captureDevice isFocusPointOfInterestSupported])
        {
            [self.captureDevice setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
        }
        
        [self.captureDevice unlockForConfiguration];
    }
}

#pragma mark - Capture
- (void)startScanQRCode
{
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authorizationStatus == AVAuthorizationStatusNotDetermined)
    {
        [self requestAccessForQRScan];
    }
    else if (authorizationStatus == AVAuthorizationStatusAuthorized)
    {
        [self _startScanQRCode];
    }
    else
    {
        // Access denied
        [self.delegate ICQRCodeViewController:self accessDenied:authorizationStatus];
    }
}

- (void)_startScanQRCode
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(_startScanQRCode) withObject:nil waitUntilDone:NO];
        return;
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if (self.captureDeviceSession == nil)
    {
        // Capture
        self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        if ([self.captureDevice lockForConfiguration:&error] )
        {
            if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            {
                [self.captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            else if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
            {
                [self.captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            }
            
            if ([self.captureDevice isFocusPointOfInterestSupported])
            {
                 [self.captureDevice setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
            }
            
            [self.captureDevice unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }

        self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
        self.captureDeviceOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.captureDeviceOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        // Session
        self.captureDeviceSession = [[AVCaptureSession alloc]init];
        
        if ([self.captureDeviceSession canSetSessionPreset:AVCaptureSessionPresetHigh])
        {
            [self.captureDeviceSession setSessionPreset:AVCaptureSessionPresetHigh];
        }
        
        if ([self.captureDeviceSession canAddInput:self.captureDeviceInput])
        {
            [self.captureDeviceSession addInput:self.captureDeviceInput];
        }
        
        if ([self.captureDeviceSession canAddOutput:self.captureDeviceOutput])
        {
            [self.captureDeviceSession addOutput:self.captureDeviceOutput];
        }
        
        // AVMetadataObjectTypeQRCode
        NSArray *availableMetadata = [self.captureDeviceOutput availableMetadataObjectTypes];
        if ([availableMetadata containsObject:AVMetadataObjectTypeQRCode])
        {
            self.captureDeviceOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        }
        
        // Preview
        self.capturePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureDeviceSession];
        self.capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.capturePreviewLayer.frame = self.view.bounds;
        [self.view.layer insertSublayer:self.capturePreviewLayer atIndex:0];
    }
    
    // Start
    if (![self.captureDeviceSession isRunning])
    {
        [self.captureDeviceSession startRunning];
        
        // Avoid capturePreviewLayer flashing-in too sudden
        [UIView animateWithDuration:0.5
                         animations:^{
                             
                             self.bgMaskView.alpha = 0;
                         }];
    }
    
#endif
}

- (void)stopScanQRCode
{
    if ([self.captureDeviceSession isRunning])
    {
        [self.captureDeviceSession stopRunning];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *resultString = nil;
    if ([metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        resultString = metadataObject.stringValue;
    }
    
    if ([resultString length] > 0)
    {
        [self didFinishScanQRCode:resultString];
    }
}

- (void)didFinishScanQRCode:(NSString *)resultString
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(didFinishScanQRCode:) withObject:resultString waitUntilDone:NO];
        return;
    }
    
    [self stopScanQRCode];
    [self.delegate ICQRCodeViewController:self didFinishScanQRCode:resultString];
}

@end
