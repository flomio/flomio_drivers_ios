//
//  NFCMitareCardViewController.h
//  com.ftsafe.aR530.demo
//
//  Created by 李亚林 on 15/1/8.
//  Copyright (c) 2015年 李亚林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTaR530.h"
#import "utils.h"

#define ALERTVIEW_ERROR_RETURN_TAG 2080
#define ALERTVIEW_NOERROR_TAG 2079


@interface NFCMifareCardViewController : UIViewController<FTaR530Delegate, UITextFieldDelegate>{
    FTaR530 *_ar530;
}

@property (weak, nonatomic) IBOutlet UITextField *sectNO_TF;
@property (weak, nonatomic) IBOutlet UITextField *storeNo_TF;
@property (weak, nonatomic) IBOutlet UITextField *KeyType_TF;
@property (weak, nonatomic) IBOutlet UIButton *AuthenticationBT;
@property (weak, nonatomic) IBOutlet UIButton *valueBlockBT;
@property (weak, nonatomic) IBOutlet UIButton *binaryBlockBT;

@property (nonatomic) id rootViewDelegate;
@property (nonatomic) UIViewController * mTempVC;
@property (nonatomic) BOOL mIsAuthentication ;

-(IBAction) authenticationFun:(id)sender;
-(IBAction) changeToValueBlockView:(id)sender;
-(IBAction) changeToTransmitView:(id)sender;
-(IBAction) Disconnect:(id)sender;

@end
