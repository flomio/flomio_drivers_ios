//
//  NFCGeneralCardViewController.mm
//  com.ftsafe.aR530.demo
//
//  Created by 李亚林 on 14/12/25.
//  Copyright (c) 2014年 李亚林. All rights reserved.
//

#import "NFCGeneralCardViewController.h"
#import "PropertyTableViewController.h"

extern nfc_card_t NFC_Card;
@interface NFCGeneralCardViewController ()

@end

@implementation NFCGeneralCardViewController

@synthesize bIsNeedDisconnect ;
@synthesize cardType ;
@synthesize rootViewDelegate ;
@synthesize autoCompleter;

@synthesize TransmitTextView ;
@synthesize txtTransmitInput ;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _ar530 = [FTaR530 sharedInstance];
    
    self.TransmitTextView.text = @"" ;
    self.txtTransmitInput.text = @"" ;
    [self.txtTransmitInput setDelegate:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --View Control function--
- (IBAction)onTransmit:(id)sender {
    
    NSString *apduText = self.txtTransmitInput.text;
    
    int nPos = 0;
    char apduStr[1024] = {0} ;
    char IDm[16 + 1] = {0};
    const char * ptmpStr = [apduText UTF8String];
    unsigned char apduBuf[100] = {0};
    unsigned int apduLen = 0;

    if(apduText == nil || [apduText isEqualToString:@""] ){
        [self showMsg:@"APDU is error!" returnAfterShow:NO];
        return;
    }
    
    if(self.cardType == CARD_TYPE_C){
        memcpy(apduStr + nPos, ptmpStr, 2) ;
        nPos += 2 ;
        
        HexToStr(IDm, NFC_Card->IDm, 8);
        memcpy(apduStr + nPos, IDm, 16) ;
        nPos += 16 ;
        
        memcpy(apduStr + nPos, ptmpStr+2 , [apduText length] - 2) ;
        nPos += [apduText length] - 2 ;
        
        apduLen = nPos / 2;
        
    }
    else{
        memcpy(apduStr, ptmpStr, [apduText length]) ;
        apduLen = (unsigned int)[apduText length] / 2;
    }
    
    StrToHex(apduBuf, (char *)apduStr, (unsigned int)apduLen);
    
    NSString *sendLog = [NSString stringWithFormat:@"send:\n%s", ptmpStr];
    self.TransmitTextView.text = sendLog;
    
    [_ar530 NFC_Card_Transmit:NFC_Card sendBuf:apduBuf sendLen:apduLen delegate:self];
}

-(IBAction)disconnect:(id)sender{

    self.TransmitTextView.text = @"" ;
    self.txtTransmitInput.text = @"" ;
    
    if(bIsNeedDisconnect == YES)
        [_ar530 NFC_Card_Close:NFC_Card delegate:self] ;
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:^{
            if (rootViewDelegate != nil) {
                [_ar530 setDeviceEventDelegate:rootViewDelegate];
            }
        }];
    });
}
- (IBAction)OnCusTransmit:(UIButton *)sender {
    NSString *apduText = self.txtTransmitInput.text;
    
    int nPos = 0;
    char apduStr[1024] = {0} ;
    char IDm[16 + 1] = {0};
    const char * ptmpStr = [apduText UTF8String];
    unsigned char apduBuf[100] = {0};
    unsigned int apduLen = 0;
    
    if(apduText == nil || [apduText isEqualToString:@""] ){
        [self showMsg:@"APDU is error!" returnAfterShow:NO];
        return;
    }
    
    if(self.cardType == CARD_TYPE_C){
        memcpy(apduStr + nPos, ptmpStr, 2) ;
        nPos += 2 ;
        
        HexToStr(IDm, NFC_Card->IDm, 8);
        memcpy(apduStr + nPos, IDm, 16) ;
        nPos += 16 ;
        
        memcpy(apduStr + nPos, ptmpStr+2 , [apduText length] - 2) ;
        nPos += [apduText length] - 2 ;
        
        apduLen = nPos / 2;
        
    }
    else{
        memcpy(apduStr, ptmpStr, [apduText length]) ;
        apduLen = (unsigned int)[apduText length] / 2;
    }
    
    StrToHex(apduBuf, (char *)apduStr, (unsigned int)apduLen);
    
    NSString *sendLog = [NSString stringWithFormat:@"send:\n%s", ptmpStr];
    self.TransmitTextView.text = sendLog;
    
    [_ar530 NFC_Card_No_Head_Transmit:NFC_Card sendBuf:apduBuf sendLen:apduLen delegate:self];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.txtTransmitInput resignFirstResponder];
    [self.autoCompleter hideOptionsView] ;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self.autoCompleter hideOptionsView] ;
    return YES;
}

#pragma mark --My Methods--

- (AutocompletionTableView *)autoCompleterData
{
    
    if (!self.autoCompleter )
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        [options setValue:[NSNumber numberWithBool:YES] forKey:ACOCaseSensitive];
        [options setValue:nil forKey:ACOUseSourceFont];
        
        self.autoCompleter = [[AutocompletionTableView alloc] initWithTextField:self.txtTransmitInput inViewController:self withOptions:options];
    }
    
    // Throught the card type to choose the right command
    if (self.cardType == CARD_TYPE_C) {
        self.autoCompleter.suggestionsDictionary = [NSArray arrayWithObjects:@"06010901018000",
                                                    nil];
    }
    else{
        //customer can do add more APDUs here
        self.autoCompleter.suggestionsDictionary = [NSArray arrayWithObjects:@"00a404000a01020304050607080900",
                                                    @"80200000EE",
                                                    @"80200000FF",
                                                    @"80300000FA00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                                    nil];
    }
    
    return self.autoCompleter;
}

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

-(void)getTransmitResult:(unsigned char *)retData retDataLen:(unsigned int)retDataLen errCode:(unsigned int)errCode
{
    NSString *recvLog = nil ;
    
    if(0 == errCode) {
        char resultStr[1024] = {0};
        HexToStr(resultStr, retData, retDataLen);
        recvLog = [NSString stringWithFormat:@"recv:\n%s",resultStr];
        
        self.TransmitTextView.text = [NSString stringWithFormat:@"%@\n%@",self.TransmitTextView.text, recvLog];
    }
    else if(NFC_CARD_ES_NO_SMARTCARD == errCode) {
        [self showMsg:@"Not Found SmartCard! Please Reconnect with Reader!" returnAfterShow:YES];
    }
    else if(retDataLen >= 2){
        char resultStr[1024] = {0};
        HexToStr(resultStr, retData, retDataLen);
        recvLog = [NSString stringWithFormat:@"recv:\n%s",resultStr];
        
        self.TransmitTextView.text = [NSString stringWithFormat:@"%@\n%@",self.TransmitTextView.text, recvLog];
    }
    else{
        [self showMsg:@"NFC_transmit failed!" returnAfterShow:NO];
    }
    
}

-(void) leaveView{
    [self.rootViewDelegate FTaR530DidDisconnected];
}

#pragma mark - FTaR530 delegate methods
- (void)FTaR530DidConnected{
    // When you set delegate when enter to page, it will call didconnect API automatic
    NSLog(@"G didconnect") ;
    
    // Add data to textfiel 
    [self.txtTransmitInput addTarget:self.autoCompleterData action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [self.txtTransmitInput addTarget:self.autoCompleterData action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingChanged];
}

-(void)FTaR530DidDisconnected{
    NSLog(@"G disconnect") ;
    
    if (rootViewDelegate != nil) {
        [_ar530 setDeviceEventDelegate:rootViewDelegate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        self.TransmitTextView.text = @"" ;
        self.txtTransmitInput.text = @"" ;
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self performSelector:@selector(leaveView) withObject:nil afterDelay:0.1];
        }];
    });
}

- (void)FTNFCDidComplete:(nfc_card_t)cardHandle retData:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)funcNum errCode:(unsigned int)errCode
{
    switch (funcNum) {
        case FT_FUNCTION_NUM_TRANSMIT:{
            NSLog(@"FT_FUNCTION_NUM_TRANSMIT") ;
            [self getTransmitResult:retData retDataLen:retDataLen errCode:errCode];
            break ;
        }
        default:
            break;
    }
}

@end
