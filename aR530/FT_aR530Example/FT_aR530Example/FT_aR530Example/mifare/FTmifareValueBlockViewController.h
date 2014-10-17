//
//  FTmifareValueBlockViewController.h
//  FTCRa520Test
//
//  Created by Li Yuelei on 7/15/13.
//  Copyright (c) 2013 FT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FT_aR530.h"
@interface FTmifareValueBlockViewController : UIViewController<UITextFieldDelegate, FTaR530Delegate>
{
    UITextField *valueAmountTF;
    UITextField *sectNo_TF;
    UITextField *blockNO_TF;
}

@property(nonatomic, retain) UITextField *valueAmountTF;
@property(nonatomic, retain) UITextField *sectNo_TF;
@property(nonatomic, retain) UITextField *blockNO_TF;

-(void)dismissSelfView;

@end
