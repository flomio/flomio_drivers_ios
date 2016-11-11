//
//  NFCMiareCardValueBlockViewController.h
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

@interface NFCMifareCardValueBlockViewController : UIViewController<FTaR530Delegate, UITextFieldDelegate>{
    FTaR530 *_ar530;
}


@property (weak, nonatomic) IBOutlet UITextField *valueAmountTF;
@property (weak, nonatomic) IBOutlet UITextField *sectNo_TF;
@property (weak, nonatomic) IBOutlet UITextField *blockNO_TF;

@property (nonatomic) id vcMifareCardDelegate;

-(IBAction)initialBlockFun:(id)sender;
-(IBAction)StoreValueFun:(id)sender;
-(IBAction)incrementFun:(id)sender;
-(IBAction)DecrementFun:(id)sender;
-(IBAction)readValueFun:(id)sender;
-(IBAction)returnToMifare:(id)sender;
@end
