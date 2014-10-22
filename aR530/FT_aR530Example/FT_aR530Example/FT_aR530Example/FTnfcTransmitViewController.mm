//
//  FTnfcTransmitViewController.m
//  FT_aR530Example
//
//  Created by yuanzhen on 14/6/12.
//  Copyright (c) 2014年 FTSafe. All rights reserved.
//

#import "FTnfcTransmitViewController.h"
#import "include/FT_aR530.h"
#import "include/utils.h"
#import "FTnfcConnectionTableViewController.h"
#import "mifare/FTMifareClassicViewController.h"
#import "AutocompletionTableView.h"

#define ALERTVIEW_ERROR_RETURN_TAG 2080
#define ALERTVIEW_NOERROR_TAG 2079

nfc_card_t NFC_Card;
FTMifareClassicViewController *MifareObj = nil;
bool isShowMifare = false;

@interface FTnfcTransmitViewController () <FTaR530Delegate,UIAlertViewDelegate,UITextFieldDelegate>
- (IBAction)onTransmit:(id)sender;
- (IBAction)onBackgroundTouched:(id)sender;
- (IBAction)onClearOutput:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *txtTransmitInput;
@property (strong, nonatomic) IBOutlet UITextView *txtTransmitOutput;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) AutocompletionTableView *autoCompleter;


@end

@implementation FTnfcTransmitViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (AutocompletionTableView *)autoCompleter
{
    if (!_autoCompleter)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        [options setValue:[NSNumber numberWithBool:YES] forKey:ACOCaseSensitive];
        [options setValue:nil forKey:ACOUseSourceFont];
        
        _autoCompleter = [[AutocompletionTableView alloc] initWithTextField:self.txtTransmitInput inViewController:self withOptions:options];
        _autoCompleter.suggestionsDictionary = [NSArray arrayWithObjects:@"06010901018000",
                                                @"0084000008",
                                                @"ff00000020d440011d02010105017010211009ffff000000080a0214010a030e040a090807",
                                                @"ff00000027d44001241001010501701021100200000008060a0214010a030e040a090807cad67ccb0e19fed9",
                                                @"ff00000015d44001121201010501701021106f61b1449a7ca7b5",
                                                @"ff0000002dd440012a14a9b7e6fa11fd61339b0b93145316d07db54fbe5ea97ecbad4d077c98eca1f31d2360dc87d58df6c4",
                                                @"ff0000002dd440012a1486143a1daaa961b97aeb6c19d8e030d65d2c86c7a612bb82ff26d6b6f072ed09c868620963466fee",
                                                @"ff0000002dd440012a14f132f7fa064d0e57c71eaac1e49040c8e37e6b94e7f4c0ef0a3985c863b20b1ea8d48b1a38f8fc0a",
                                                @"ff0000001dd440011a1479052fdf72316d91c08b0fe62c801be6008384cd61d2afd2",
                                                @"ff00000003d44001",
                                                @"00A4040005112233445566",
                                                @"8010010000",
                                                @"00A404000733333333333333",
                                                @"8010007000",
                                                @"8010012100",
                                                nil];
    }
    return _autoCompleter;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"7.0" options: NSNumericSearch];

    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        if (order == NSOrderedSame || order == NSOrderedDescending)
        {
            // OS version >= 7.0
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    
    _txtTransmitOutput.layer.borderColor = [UIColor blackColor].CGColor;
    _txtTransmitOutput.layer.borderWidth = 1.5;
    _txtTransmitOutput.layer.cornerRadius = 4;
    self.view.backgroundColor = [UIColor grayColor];
    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _indicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.view addSubview:_indicatorView];
    UILabel *hintInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    hintInfo.text = @"Waiting for swipe/touch card";
    hintInfo.textAlignment = NSTextAlignmentCenter;
    hintInfo.backgroundColor = [UIColor clearColor];
    hintInfo.textColor = [UIColor whiteColor];
    [_indicatorView addSubview:hintInfo];
    [_txtTransmitInput addTarget:self.autoCompleter action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [_txtTransmitInput addTarget:self.autoCompleter action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingChanged];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    _indicatorView.hidden = NO;
    [_indicatorView startAnimating];
    [self readCard];
    
}
- (void)viewWillDisappear:(BOOL)animated
{

    _indicatorView.hidden = YES;
    [_indicatorView stopAnimating];
    stopRetry = YES;
    [FTaR530 NFC_Card_Close:NFC_Card delegate:nil];
    [FTaR530 removeDelegate];
}

- (void)readCard
{
    g_cardType = _cardType;
    [FTaR530 NFC_Card_Open:self withTimeout:_timeout withRetryCount:_retryCount];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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


- (IBAction)onTransmit:(id)sender {
    NSString *apduText = _txtTransmitInput.text;
    if(apduText == nil || [apduText isEqualToString:@""]){
        [self showMsg:@"APDU is empty!" returnAfterShow:NO];
        return;
    }
    
    const char *apduStr = [apduText UTF8String];
    unsigned char apduBuf[100] = {0};
    unsigned int apduLen = 0;
    
    apduLen = [apduText length] / 2;
    StrToHex(apduBuf, (char *)apduStr, [apduText length]);
    
    NSString *sendLog = [NSString stringWithFormat:@"send:\n%@",apduText];
    [self performSelectorOnMainThread:@selector(showResultFun:) withObject:sendLog waitUntilDone:YES];
    [FTaR530 NFC_Card_Transmit:NFC_Card sendBuf:apduBuf sendLen:apduLen delegate:self];
}

-(void)getConnectResult:(nfc_card_t)cardHandle
{
    NFC_Card = cardHandle;
    if(NFC_Card != 0) {
        [FTaR530 NFC_Card_Recognize:NFC_Card delegate:self];
    }else {
        [self showMsg:@"nfc_card_open failed!" returnAfterShow:YES];
    }
}
-(void)getRecognizeResult:(nfc_card_t)cardHandle cardType:(unsigned int)errCode
{
    
    if(errCode == 0xFF) {
        [self showMsg:@"Recongnize Card failed!" returnAfterShow:YES];
        return;
    }
    
    unsigned int cardT = 0;
    NSString *MsgShowing = nil;
    char uid[128] = {0};
    
    char IDm[16 + 1] = {0};
    char PMm[16 + 1] = {0};
    
    char pupi[64] = {0};
    
    HexToStr(uid, cardHandle->uid, cardHandle->uidLen);
    
    cardT = errCode;
    
    
    if(cardHandle->type == CARD_TYPE_A) {
        if(cardT == CARD_NXP_MIFARE_1K) {
            if(MifareObj == nil) {
                MifareObj = [[FTMifareClassicViewController alloc] init];
            }
//            [self presentModalViewController:MifareObj animated:YES];
            [self presentViewController:MifareObj animated:YES completion:^(void){[self.navigationController popViewControllerAnimated:NO];}];
            isShowMifare = true;
        }else if(cardT == CARD_NXP_DESFIRE_EV1) {
            //            FTDesfireViewController *desfireObj = [[[FTDesfireViewController alloc] init] autorelease];
            //            [self presentModalViewController:desfireObj animated:YES];
            MsgShowing = [NSString stringWithFormat:@"Mifare Desfire\nUID:%s", uid];
            [self showMsg:MsgShowing returnAfterShow:NO];
        }else if(cardT == CARD_NXP_MIFARE_UL) {
            MsgShowing = [NSString stringWithFormat:@"Mifare Ultralight\nUID:%s",uid];
            [self showMsg:MsgShowing returnAfterShow:NO];
        }else {
            MsgShowing = [NSString stringWithFormat:@"Card Type:A\nUID:%s", uid];
            [self showMsg:MsgShowing returnAfterShow:NO];
        }
    }else if(cardHandle->type == CARD_TYPE_B) {
        if(cardT == CARD_NXP_M_1_B) {
            if(MifareObj == nil) {
                MifareObj = [[FTMifareClassicViewController alloc] init];
            }
             [self presentViewController:MifareObj animated:YES completion:^(void){[self.navigationController popViewControllerAnimated:NO];}];
            isShowMifare = true;
        }else if(cardT == CARD_NXP_TYPE_B) {
            HexToStr(pupi, cardHandle->PUPI, cardHandle->PUPILen);
            MsgShowing = [NSString stringWithFormat:@"Card Type:B\nPUPI:%s", pupi];
            [self showMsg:MsgShowing returnAfterShow:NO];
        }
    }else if(cardHandle->type == CARD_TYPE_C) {
        HexToStr(IDm, cardHandle->IDm, 8);
        HexToStr(PMm, cardHandle->PMm, 8);
        
        MsgShowing = [NSString stringWithFormat:@"Felica\nIDm:%s\nPMm:%s", IDm, PMm];
        [self showMsg:MsgShowing returnAfterShow:NO];
    } else if(cardHandle->type == CARD_TYPE_D) {
        [self showMsg:@"Connect Success!" returnAfterShow:NO];
    }
    
}

-(void)getDisconnectResult:(unsigned int)errCode
{
    if(0 == errCode) {
        [self showMsg:@"NFC_disconnect success!" returnAfterShow:YES];
    }else {
        [self showMsg:[NSString stringWithFormat:@"NFC_disconnect failed:%0X", errCode] returnAfterShow:NO];
    }
}
-(void)showResultFun:(NSString *)result {
    _txtTransmitOutput.text = [NSString stringWithFormat:@"%@%@\n", _txtTransmitOutput.text, result];
    [_txtTransmitOutput scrollRectToVisible:CGRectMake(0, 0, _txtTransmitOutput.contentSize.width, _txtTransmitOutput.contentSize.height) animated:YES];
}


-(void)getTransmitResult:(unsigned char *)retData retDataLen:(unsigned int)retDataLen errCode:(unsigned int)errCode
{
    
    if(0 == errCode) {
        char resultStr[1024] = {0};
        HexToStr(resultStr, retData, retDataLen);
        NSString *recvLog = [NSString stringWithFormat:@"recv:\n%s",resultStr];
        
        [self performSelectorOnMainThread:@selector(showResultFun:) withObject:recvLog waitUntilDone:YES];
    }else if(NFC_CARD_ES_NO_SMARTCARD == errCode) {
        [self showMsg:@"Not Found SmartCard! Please Reconnect with Reader!" returnAfterShow:YES];
    }else if(retDataLen >= 2){
        char resultStr[1024] = {0};
        HexToStr(resultStr, retData, retDataLen);
        NSString *recvLog = [NSString stringWithFormat:@"recv:\n%s",resultStr];
        
        [self performSelectorOnMainThread:@selector(showResultFun:) withObject:recvLog waitUntilDone:YES];
    }else{
        [self showMsg:@"NFC_transmit failed!" returnAfterShow:NO];
    }
    
}

- (IBAction)onBackgroundTouched:(id)sender
{
    [_txtTransmitInput resignFirstResponder];
}
- (IBAction)onClearOutput:(id)sender
{
    _txtTransmitOutput.text = @"";
}


#pragma mark - FTaR530 delegate methods
- (void)FTNFCDidComplete:(nfc_card_t)cardHandle retData:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)funcNum errCode:(unsigned int)errCode
{
    switch (funcNum) {
        case FT_FUNCTION_NUM_OPEN_CARD:
            [self getConnectResult:cardHandle];
            _indicatorView.hidden = YES;
            [_indicatorView stopAnimating];
            break;
        case FT_FUNCTION_NUM_RECOGNIZE:
            [self getRecognizeResult:cardHandle cardType:errCode];
            break;
        case FT_FUNCTION_NUM_CLOSE_CARD:
            [self getDisconnectResult:errCode];
        case FT_FUNCTION_NUM_TRANSMIT:
            [self getTransmitResult:retData retDataLen:retDataLen errCode:errCode];
        default:
            break;
    }
}


#pragma mark - AlertView delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERTVIEW_ERROR_RETURN_TAG) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - segue methods

@end
