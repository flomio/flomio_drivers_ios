//
//  PropertyTableViewController.mm
//  com.ftsafe.aR530.demo
//
//  Created by 李亚林 on 14/12/25.
//  Copyright (c) 2014年 李亚林. All rights reserved.
//

#import "PropertyTableViewController.h"
#import "NFCGeneralCardViewController.h"
#import "NFCMifareCardViewController.h"
#import "NotfoundViewController.h"

#define SOFTWARE_VERSION @"Software Version: 1.0.6"

nfc_card_t NFC_Card;
@interface PropertyTableViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *VIndicator;
@property (strong, nonatomic) NotfoundViewController *vcWarning;
@property (strong, nonatomic) NFCGeneralCardViewController *vcGeneralCardView;
@property (strong, nonatomic) NFCMifareCardViewController *vcMifareCardView;

@end

@implementation PropertyTableViewController

@synthesize VIndicator ;
@synthesize vcWarning ;
@synthesize vcGeneralCardView ;
@synthesize vcMifareCardView ;
@synthesize softwareVersion ;

BOOL isOpen = NO ;
BOOL isTransmit = NO ;
UIViewController * tempVC = nil ;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*************  Init Variable  ***************/
    _ar530 = [FTaR530 sharedInstance];
    [_ar530 setDeviceEventDelegate:self];
    
    self.softwareVersion.text = SOFTWARE_VERSION ;
    
    _libVersion.text = [NSString stringWithFormat:@"Library version:%@", [_ar530 getLibVersion],nil];
    _deviceID.text = @"Device ID:...";
    _firmwareVersion.text = @"Firmware Version:...";
    _deviceUID.text = @"Device UID:...";
    
    /*************  wait subview  ***************/
    self.VIndicator = [[UIActivityIndicatorView alloc] initWithFrame: self.view.bounds];
    self.VIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.VIndicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.view addSubview:self.VIndicator];
    
    UILabel *hintInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    hintInfo.text = @"Get device info ...";
    hintInfo.textAlignment = NSTextAlignmentCenter;
    hintInfo.backgroundColor = [UIColor clearColor];
    hintInfo.textColor = [UIColor whiteColor];
    [self.VIndicator addSubview:hintInfo];
    
    /*************  View Controller  ***************/
    if(self.vcWarning == nil){
        self.vcWarning = [self.storyboard instantiateViewControllerWithIdentifier:SID_DEVICE_NOTFOUND];
    }
    
    if(self.vcGeneralCardView == nil){
        self.vcGeneralCardView = [self.storyboard instantiateViewControllerWithIdentifier:SID_VIEW_GENERALCARD];
    }
    
    if(self.vcMifareCardView == nil){
        self.vcMifareCardView = [self.storyboard instantiateViewControllerWithIdentifier:SID_VIEW_MIFARECARD];
    }
    
    _properTable.scrollEnabled = NO ;
    self.VIndicator.hidden = NO;
    [self.VIndicator startAnimating];
    [_properTable setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.vcWarning dismissViewControllerAnimated:YES completion:^(){}];
        
        // Here we need waiting until the device has initialized
        [NSThread sleepForTimeInterval:2.5f] ;
        [ _ar530 getDeviceID:self];
    });
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_ar530 NFC_Card_Close:NFC_Card delegate:nil];
}


#pragma mark --View control function--
-(IBAction)Connect:(id)sender{
    
    // get the card type
    Byte cardType = 0;
    if (_switchA.isOn) {
        cardType |= A_CARD;
    }
    if (_switchB.isOn) {
        cardType |= B_CARD;
    }
    if (_switchFelica.isOn) {
        cardType |= Felica_CARD;
    }
    if (_switchMifare.isOn) {
        cardType |= Topaz_CARD;
    }
    
    _ar530.cardType = cardType;
    [_ar530 NFC_Card_Open:self];
    
}
- (IBAction)PlaySound:(UIButton *)sender {
    [_ar530 playSound:self ];
}
- (IBAction)CloseSound:(UIButton *)sender {
    [_ar530 disabbleConnectSound:self];
}


- (void)aquireFirmwareVersion
{
    [_ar530 getFirmwareVersion:self];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark --My Methods--
-(void)showMsg:(NSString *)message returnAfterShow:(BOOL)ras
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    if (ras) {
        alertView.tag = ALERTVIEW_ERROR_RETURN_TAG;
    }else{
        alertView.tag = ALERTVIEW_NOERROR_TAG;
    }
    alertView.delegate = self;
    [alertView show];
}

-(void)getRecognizeResult:(nfc_card_t)cardHandle cardType:(unsigned int)errCode
{
    if(errCode == 0xFF) {
        [self showMsg:@"Recongnize Card failed!" returnAfterShow:YES];
        return;
    }
    
    unsigned int cardT = 0;
    NSString *tempkeyType = @"";
    NSString *MsgShowing = nil;
    char uid[128] = {0};
    char IDm[16 + 1] = {0};
    char PMm[16 + 1] = {0};
    char pupi[64] = {0};
//    char atqa[4+1] = {0} ;
    
    
    HexToStr(uid, cardHandle->uid, cardHandle->uidLen);
    
    // The default view is general view
    tempVC = self.vcGeneralCardView ;
    cardT = errCode;
    isOpen = YES ;
    
    // get the card type
    if(cardHandle->type == CARD_TYPE_A) {
        tempkeyType = @"A" ;
        if(cardT == CARD_NXP_MIFARE_1K || cardT == CARD_NXP_MIFARE_4K){
            
            MsgShowing = [NSString stringWithFormat:@"Card Type:Mifare 1K\nSAK:%02x UID:%s", cardHandle->SAK, uid];
            [self showMsg:MsgShowing returnAfterShow:NO];
            tempVC = self.vcMifareCardView ;
        }else if(cardT == CARD_NXP_DESFIRE_EV1) {
            
            MsgShowing = [NSString stringWithFormat:@"Card Type:A\nSAK:%02x UID:%s", cardHandle->SAK, uid];
            [self showMsg:MsgShowing returnAfterShow:NO];
        }else if(cardT == CARD_NXP_MIFARE_UL) {
            
            MsgShowing = [NSString stringWithFormat:@"Card Type:Mifare 1K\nSAK:%02x UID:%s", cardHandle->SAK, uid];
            [self showMsg:MsgShowing returnAfterShow:NO];
        }else {
            
            MsgShowing = [NSString stringWithFormat:@"Card Type:A\nSAK:%02x UID:%s", cardHandle->SAK, uid];
            [self showMsg:MsgShowing returnAfterShow:NO];
        }
    }
    else if(cardHandle->type == CARD_TYPE_B) {
        tempkeyType = @"B" ;
        if(cardT == CARD_NXP_M_1_B) {
            
            HexToStr(pupi, cardHandle->PUPI, cardHandle->PUPILen);
            MsgShowing = [NSString stringWithFormat:@"Card Type:B\nATQB:%02x PUPI:%s", cardHandle->ATQB, pupi];
            [self showMsg:MsgShowing returnAfterShow:NO];
            tempVC = self.vcMifareCardView ;
        }else if(cardT == CARD_NXP_TYPE_B) {
            
            HexToStr(pupi, cardHandle->PUPI, cardHandle->PUPILen);
            MsgShowing = [NSString stringWithFormat:@"Card Type:B\nATQB:%02x PUPI:%s", cardHandle->ATQB, pupi];
            [self showMsg:MsgShowing returnAfterShow:NO];
        }
    }
    else if(cardHandle->type == CARD_TYPE_C) {                  // Felica
        
        HexToStr(IDm, cardHandle->IDm, 8);
        HexToStr(PMm, cardHandle->PMm, 8);
        MsgShowing = [NSString stringWithFormat:@"Card Type:Felica\nFelica_ID:%s\nPad_ID:%s", IDm, PMm];
        [self showMsg:MsgShowing returnAfterShow:NO];
    }
    else if(cardHandle->type == CARD_TYPE_D) {                  // Topaz
        
        HexToStr(pupi, cardHandle->PUPI, cardHandle->PUPILen);
        MsgShowing = [NSString stringWithFormat:@"Card Type:Topaz\nATQA:%2s ID1z:%s", cardHandle->ATQA, pupi];
        [self showMsg:MsgShowing returnAfterShow:NO];
    }
    else{
        MsgShowing = [NSString stringWithFormat:@"Unknown type of card !"];
        [self showMsg:MsgShowing returnAfterShow:NO];
        return ;
    }
    
    // Throught the different card type, switch to different view
    if (tempVC == self.vcGeneralCardView || tempVC == self.vcMifareCardView) {
        [self presentViewController:tempVC animated:YES completion:^(void){
            
            if(tempVC == self.vcMifareCardView){
                self.vcMifareCardView.KeyType_TF.text = tempkeyType ;
                self.vcMifareCardView.rootViewDelegate = self ;
                
                // set delegate to sub-view
                [_ar530 setDeviceEventDelegate:self.vcMifareCardView];
            }
            else {

                self.vcGeneralCardView.bIsNeedDisconnect = YES;
                self.vcGeneralCardView.cardType = cardHandle->type;
                self.vcGeneralCardView.rootViewDelegate = self ;

                // set delegate to sub-view
                [_ar530 setDeviceEventDelegate:self.vcGeneralCardView];
            }
            isTransmit = YES ;
        }];
    }
}


-(void)getConnectResult:(nfc_card_t)cardHandle
{
    if(cardHandle != 0) {
        NFC_Card = cardHandle;
        [_ar530 NFC_Card_Recognize:NFC_Card delegate:self];
    }
    else{
        [self showMsg:@"NFC_card_open failed!" returnAfterShow:YES];
    }
    
}

#pragma mark --FTaR530Delegate Methods--
- (void)FTaR530DidConnected{
    
    NSLog(@"R connected") ;
    if(isOpen == YES){
        return ;
    }
    
    _properTable.scrollEnabled = NO ;
    self.VIndicator.hidden = NO;
    [self.VIndicator startAnimating];
    [_properTable setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.vcWarning dismissViewControllerAnimated:YES completion:^(){
        
            // Here we need waiting until the device has initialized
            [NSThread sleepForTimeInterval:2.5f] ;
            [ _ar530 getDeviceID:self];
            isOpen = YES ;
        }];
    });
    
}

- (void)FTaR530DidDisconnected{
    NSLog(@"R disconnect") ;
  
    //release
    if (isOpen == NO) {
        return ;
    }
    isOpen = NO ;
    
    
    if(self.VIndicator.hidden == NO){
        self.VIndicator.hidden = YES;
        [self.VIndicator stopAnimating];
    }
  
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        // Add try catch, when the reader has plug-in/out, we need update the view
        try {
            
            [self presentViewController:self.vcWarning animated:YES completion:^(void){
            
                isTransmit = NO;
                tempVC = nil ;
                _libVersion.text = [NSString stringWithFormat:@"Library version:%@", [_ar530 getLibVersion],nil];
                _deviceID.text = @"Device ID:...";
                _firmwareVersion.text = @"Firmware Version:...";
            }];
            
        }
        catch (...) {
            NSLog(@" error !") ;
            _deviceID.text = @"Device ID:...";
            _firmwareVersion.text = @"Firmware Version:...";
        }
        
        
    });
}

- (void)FTaR530GetInfoDidComplete:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)functionNum errCode:(unsigned int)errCode
{
    NSString *retString = [NSString stringWithUTF8String:(char*)retData];
    switch (functionNum) {
        case FT_FUNCTION_NUM_GET_DEVICEID:{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                if (retString.length <= 0) {
                    isOpen = NO ;
                    [self presentViewController:self.vcWarning animated:YES completion:^(void){ }];
                    return ;
                }
                
                // lib version
                _libVersion.text = [NSString stringWithFormat:@"Library version:%@", [_ar530 getLibVersion],nil];
                // device ID
                _deviceID.text = [NSString stringWithFormat:@"Device ID:%@",retString,nil];
                
                [self aquireFirmwareVersion];
                
            });
            break;
        }
        case FT_FUNCTION_NUM_GET_DEVICEUID:{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                // device UID
                _deviceUID.text = [NSString stringWithFormat:@"Device UID:%@",retString,nil];
                
            });
            break;
        }
        case FT_FUNCTION_NUM_GET_FIRMWAREVERSION:{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                // firmware version
                 _firmwareVersion.text = [NSString stringWithFormat:@"Firmware Version:%@",retString,nil];
                
                // get device UID
                [ _ar530 getDeviceUID:self];
                
                isOpen = YES ;
                _properTable.scrollEnabled = YES;
                self.VIndicator.hidden = YES;
                [self.VIndicator stopAnimating];
                
            });
            break;
        }
        default:
            break;
    }
}

- (void)FTNFCDidComplete:(nfc_card_t)cardHandle retData:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)funcNum errCode:(unsigned int)errCode
{
    switch (funcNum) {
        case FT_FUNCTION_NUM_OPEN_CARD:{
            NSLog(@"FT_FUNCTION_NUM_OPEN_CARD") ;
            [self getConnectResult:cardHandle];
            break;
        }
        case FT_FUNCTION_NUM_RECOGNIZE:{
            NSLog(@"FT_FUNCTION_NUM_RECOGNIZE") ;
            [self getRecognizeResult:cardHandle cardType:errCode];
            break;
        }
        default:
            break;
    }
}
@end
