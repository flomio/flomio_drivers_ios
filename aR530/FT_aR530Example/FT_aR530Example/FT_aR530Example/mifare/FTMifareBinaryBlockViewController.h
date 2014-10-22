//
//  FTMifareBinaryBlockViewController.h
//  FTCRa520Test
//
//  Created by Li Yuelei on 7/16/13.
//  Copyright (c) 2013 FT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FT_aR530.h"

@interface FTMifareBinaryBlockViewController : UIViewController<UITextFieldDelegate, FTaR530Delegate>
{
    UITextField *sectNOTF;
    UITextField *blockNoTF;
    UITextField *lengthTF;
    UITextField *dataTF;
}

@property(nonatomic, retain) UITextField *sectNOTF;
@property(nonatomic, retain) UITextField *blockNoTF;
@property(nonatomic, retain) UITextField *lengthTF;
@property(nonatomic, retain) UITextField *dataTF;

-(void)dismissSelfView;

@end
