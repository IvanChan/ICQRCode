//
//  ICQRCodeManager.h
//  ICUIKit
//
//  Created by _ivanC on 3/25/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICQRCodeManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)isQRCodeViewPresented;
- (void)presentQRCodeView:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissQRCodeView:(BOOL)animated completion:(void (^)(void))completion;

@end
