//
//  FTMifareClassicViewController.h
//  FTCRa520Test
//
//  Created by Li Yuelei on 7/11/13.
//  Copyright (c) 2013 FT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FT_aR530.h"

@interface FTMifareClassicViewController : UIViewController<UITextFieldDelegate, FTaR530Delegate>
{
    UIButton *retBtn;
    UIButton *loadKeysBtn;
    UIButton *authenBtn;
    
    UITextField *sectNO_TF;
    UITextField *storeNo_TF;
    UITextField *keyType_TF;
    
}

@property(nonatomic, retain) UIButton *retBtn;
@property(nonatomic, retain) UIButton *loadKeysBtn;
@property(nonatomic, retain) UIButton *authenBtn;
@property(nonatomic, retain) UITextField *sectNO_TF;
@property(nonatomic, retain) UITextField *storeNo_TF;
@property(nonatomic, retain) UITextField *keyType_TF;

-(void)dismissMySelfView;

@end
