//
//  disopWindow.h
//  call_lib
//
//  Created by test on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "winscard.h"
#import "ReaderInterface.h"



@interface disopWindow : UIViewController <UITextFieldDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,ReaderInterfaceDelegate>{
    
    IBOutlet UIButton* dropList;
    IBOutlet UIButton* infoBut;
    IBOutlet UISwitch *cardState;
    
	IBOutlet UITextField *commandText;    
    IBOutlet UITextView *ATR_Label;
    IBOutlet UITextView *disTextView;
    
    IBOutlet UILabel* APDU_Label;
    
    IBOutlet UIImageView *disResp;
    IBOutlet UIImageView *apduInput;
    
    SCARDHANDLE  gCardHandle;
    
    UIView *showInfoView;
    UIView *clearView;

}

-(IBAction) showInfo;
-(IBAction) powerOnFun:(id)sender;
-(IBAction) powerOffFun:(id)sender;

-(IBAction) sendCommandFun:(id)sender;
-(IBAction) textFieldDone:(id)sender; 

-(IBAction) limitCharacter:(id)sender;
-(IBAction)runBtnPressed:(id)sender;
-(void) moveToDown;


@property (nonatomic, weak) IBOutlet UIButton *powerOn;
@property (nonatomic, weak) IBOutlet UIButton *powerOff;
@property (nonatomic, weak) IBOutlet UIButton *sendCommand;


@property (nonatomic, weak) IBOutlet UIButton *getSerialNo;
@property (nonatomic, weak) IBOutlet UIButton *getCardState;
@property (nonatomic,strong) ReaderInterface *readInf;


@property (nonatomic,weak) UIButton* runCommand;
@property (nonatomic,strong) NSArray* listData;
@property (nonatomic,strong) NSArray* showInfoData;

@end
