//
//  NFCGeneralCardViewController.h
//  com.ftsafe.aR530.demo
//
//  Created by 李亚林 on 14/12/25.
//  Copyright (c) 2014年 李亚林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTaR530.h"
#import "include/utils.h"
#import "AutocompletionTableView.h"

#define ALERTVIEW_ERROR_RETURN_TAG 2080
#define ALERTVIEW_NOERROR_TAG 2079

@interface NFCGeneralCardViewController : UIViewController<FTaR530Delegate, UIAlertViewDelegate,UITextFieldDelegate>{
    FTaR530 *_ar530;
}

@property (nonatomic) BOOL bIsNeedDisconnect;
@property (nonatomic) unsigned char cardType;
@property (nonatomic) id rootViewDelegate;
@property (nonatomic, strong) AutocompletionTableView *autoCompleter;

@property (weak, nonatomic) IBOutlet UITextView *TransmitTextView;
@property (weak, nonatomic) IBOutlet UITextField *txtTransmitInput;

@end
