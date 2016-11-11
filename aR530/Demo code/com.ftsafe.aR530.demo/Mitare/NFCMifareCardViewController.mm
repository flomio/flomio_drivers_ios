//
//  NFCMitareCardViewController.mm
//  com.ftsafe.aR530.demo
//
//  Created by 李亚林 on 15/1/8.
//  Copyright (c) 2015年 李亚林. All rights reserved.
//

#import "NFCMifareCardViewController.h"
#import "PropertyTableViewController.h"
#import "NFCMifareCardValueBlockViewController.h"

extern nfc_card_t NFC_Card;
@interface NFCMifareCardViewController ()

@property (strong, nonatomic) NFCGeneralCardViewController* vcNFCGeneralCardViewController;
@property (strong, nonatomic) NFCMifareCardValueBlockViewController* vcNFCMifareCardValueBlock;

@end

@implementation NFCMifareCardViewController

@synthesize sectNO_TF;
@synthesize storeNo_TF;
@synthesize KeyType_TF;

@synthesize mTempVC ;
@synthesize mIsAuthentication ;
@synthesize rootViewDelegate ;
@synthesize vcNFCGeneralCardViewController ;
@synthesize vcNFCMifareCardValueBlock ;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _ar530 = [FTaR530 sharedInstance];
    sectNO_TF.text = @"15" ;
    storeNo_TF.text = @"FFFFFFFFFFFF" ;
    self.mIsAuthentication = NO;
    
    
    if(self.vcNFCGeneralCardViewController == nil){
        self.vcNFCGeneralCardViewController = [self.storyboard instantiateViewControllerWithIdentifier:SID_VIEW_GENERALCARD];
    }
    
    if(self.vcNFCMifareCardValueBlock == nil){
        self.vcNFCMifareCardValueBlock = [self.storyboard instantiateViewControllerWithIdentifier:SID_VIEW_MIFARECARDVALUEBLOCK];
    }
    
    [self.sectNO_TF setDelegate:self];
    [self.storeNo_TF setDelegate:self];
    [self.KeyType_TF setDelegate:self];
    
    mTempVC = nil ;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --View Control function--
-(IBAction)authenticationFun:(id)sender{
    
    BYTE keyType;
    BYTE authenKey[6] = {0};
    unsigned int blocksNo = [[sectNO_TF text] intValue] * 4;
    
    
    if([[storeNo_TF text] length] != 12 ) {
        [self showMsg:@"Input AuthenKey length not is 12 !"];
        return;
    }
    
    const char *key_str = [[storeNo_TF text] UTF8String];
    
    if([[KeyType_TF text] isEqualToString:@"A"] || [[KeyType_TF text] isEqualToString:@"a"] ){
        keyType = 0x60;
    }
    else if([[KeyType_TF text] isEqualToString:@"B"] || [[KeyType_TF text] isEqualToString:@"b"]){
        keyType = 0x61;
    }
    else{
        [self showMsg:@"Key type Input \'A\' or \'B\'"];
        return ;
    }

    StrToHex(authenKey, (char *)key_str, strlen(key_str)/2);
    
    [_ar530 Mifare_GeneralAuthenticate:NFC_Card blockNum:blocksNo keyType:keyType key:authenKey delegate:self];
    
}

-(IBAction) changeToValueBlockView:(id)sender{

    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (self.vcNFCMifareCardValueBlock != nil) {
            [self presentViewController:self.vcNFCMifareCardValueBlock animated:YES completion:^(){
                self.vcNFCMifareCardValueBlock.vcMifareCardDelegate = self ;
                self.vcNFCMifareCardValueBlock.sectNo_TF.text = self.sectNO_TF.text;
                
                // set delegate to sub-view
                [_ar530 setDeviceEventDelegate:self.vcNFCMifareCardValueBlock];
            }];
            
            mTempVC = self.vcNFCMifareCardValueBlock;
        }
    });
}

-(IBAction)  changeToTransmitView:(id)sender{

    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (self.vcNFCGeneralCardViewController != nil) {
            [self presentViewController:self.vcNFCGeneralCardViewController animated:YES completion:^(){
                
                self.vcNFCGeneralCardViewController.bIsNeedDisconnect =  NO;
                self.vcNFCGeneralCardViewController.cardType = NFC_Card->type;
                self.vcNFCGeneralCardViewController.rootViewDelegate = self ;
                
                // set delegate to sub-view
                [_ar530 setDeviceEventDelegate:self.vcNFCGeneralCardViewController];
            }];
            
            mTempVC = self.vcNFCGeneralCardViewController;
        }
    });
}

-(IBAction) Disconnect:(id)sender{
    
    [_ar530 NFC_Card_Close:NFC_Card delegate:self] ;
    
    self.mIsAuthentication = NO ;
    if (rootViewDelegate != nil) {
        [_ar530 setDeviceEventDelegate:rootViewDelegate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:^{ }];
    });
    
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.sectNO_TF resignFirstResponder];
    [self.storeNo_TF resignFirstResponder];
    [self.KeyType_TF resignFirstResponder] ;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark --My Methods--
-(void)showMsg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)getAuthenResult:(unsigned int)errCode
{
    if(errCode == 0) {
        self.mIsAuthentication = YES ;
        [self showMsg:@"Authentication Success"];
    }else {
        self.mIsAuthentication = NO ;
        [self showMsg:@"Authentication Failed"];
    }
}


-(void) leaveView{
    [self.rootViewDelegate FTaR530DidDisconnected];
}

#pragma mark --FTaR530 delegate methods--
- (void)FTaR530DidConnected{
    NSLog(@"M didconnect") ;
}

-(void)FTaR530DidDisconnected{
    NSLog(@"M disconnect") ;
    
    self.mIsAuthentication = NO ;
    mTempVC = nil ;
    
    if (rootViewDelegate != nil) {
        [_ar530 setDeviceEventDelegate:rootViewDelegate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        // if enter to subview, will only close the current view
        [self dismissViewControllerAnimated:YES completion:^{
            [self performSelector:@selector(leaveView) withObject:nil afterDelay:0.1];
        }];
    });
}

-(void)FTNFCDidComplete:(nfc_card_t)cardHandle retData:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)funcNum errCode:(unsigned int)errCode
{
    
    NSLog(@"\nfunctionNum:%d\nerrCode:%08x\n", funcNum, errCode);
    switch (funcNum) {
        case FT_FUNCTION_NUM_AUTHENTICATE:{
            [self getAuthenResult:errCode];
            break;
        }
        default:
            break;
    }
}

@end
