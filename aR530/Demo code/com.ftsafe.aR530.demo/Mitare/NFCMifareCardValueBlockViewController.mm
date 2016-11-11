//
//  NFCMifareCardValueBlockViewController.mm
//  com.ftsafe.aR530.demo
//
//  Created by 李亚林 on 15/1/8.
//  Copyright (c) 2015年 李亚林. All rights reserved.
//

#import "NFCMifareCardValueBlockViewController.h"
#import "NFCMifareCardViewController.h"

extern nfc_card_t NFC_Card;
@interface NFCMifareCardValueBlockViewController ()

@end

@implementation NFCMifareCardValueBlockViewController
@synthesize valueAmountTF;
@synthesize sectNo_TF;
@synthesize blockNO_TF;

@synthesize vcMifareCardDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ar530 = [FTaR530 sharedInstance];
    
    // The default is 15
    self.sectNo_TF.text = @"15" ;
    self.valueAmountTF.text = @"0" ;
    self.blockNO_TF.text = @"1" ;
    
    [self.valueAmountTF setDelegate:self];
    [self.sectNo_TF setDelegate:self];
    [self.blockNO_TF setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --View Control function--
-(IBAction)initialBlockFun:(id)sender{
    
    unsigned char section = [[sectNo_TF text] intValue];
    unsigned char block = [[blockNO_TF text] intValue];
    unsigned char blockNo = [self calculateBlockNo:section BlockNumber:block];
    
    [_ar530 Mifare_ClassicBlockInitial:NFC_Card blockNum:blockNo delegate:self];
}

-(IBAction)StoreValueFun:(id)sender{
    
    BYTE section = [[sectNo_TF text] intValue];
    BYTE block = [[blockNO_TF text] intValue];
    
    unsigned char blockNo = [self calculateBlockNo:section BlockNumber:block];
    unsigned int valueAmount = [[valueAmountTF text] intValue];
    
    [_ar530 Mifare_ClassicStoreBlock:NFC_Card blockNum:blockNo valueAmount:valueAmount delegate:self];
}

-(IBAction)incrementFun:(id)sender{
    BYTE section = [[sectNo_TF text] intValue];
    BYTE block = [[blockNO_TF text] intValue];
    
    unsigned char blockNo = [self calculateBlockNo:section BlockNumber:block];
    unsigned int valueAmount = [[valueAmountTF text] intValue];
    
    [_ar530 Mifare_ClassicIncrement:NFC_Card blockNum:blockNo valueAmount:valueAmount delegate:self];
    
}

-(IBAction)DecrementFun:(id)sender{
    
    BYTE section = [[sectNo_TF text] intValue];
    BYTE block = [[blockNO_TF text] intValue];
    
    unsigned char blockNo = [self calculateBlockNo:section BlockNumber:block];
    unsigned int valueAmount = [[valueAmountTF text] intValue];
    
    [_ar530 Mifare_ClassicDecrement:NFC_Card blockNum:blockNo valueAmount:valueAmount delegate:self];
    
}

-(IBAction)readValueFun:(id)sender{
    BYTE section = [[sectNo_TF text] intValue];
    BYTE block = [[blockNO_TF text] intValue];
    
    unsigned char blockNo = [self calculateBlockNo:section BlockNumber:block];
    
    [_ar530 Mifare_ClassicReadValue:NFC_Card blockNum:blockNo delegate:self];
    
}

-(IBAction)returnToMifare:(id)sender{
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:^(){
            if (self.vcMifareCardDelegate != nil) {
                
                NFCMifareCardViewController * tmpVC = (NFCMifareCardViewController *)self.vcMifareCardDelegate;
                tmpVC.mTempVC = nil ;
                [_ar530 setDeviceEventDelegate:vcMifareCardDelegate];
            }
        }];
    });
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.valueAmountTF resignFirstResponder];
    [self.sectNo_TF resignFirstResponder];
    [self.blockNO_TF resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark --My Methods--
-(unsigned short)calculateBlockNo:(unsigned short)section BlockNumber:(unsigned short)block
{
    return section * 4 + block;
}

-(void)showMsg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)getinitBlockResult:(unsigned int)errCode
{
    
    if(errCode == 0) {
        [self showMsg:[NSString stringWithFormat:@"Block initial Success!"]];
    }
    else {
        [self showMsg:[NSString stringWithFormat:@"Block initial failed!"]];
    }
}

-(void)getStoreBlockResult:(unsigned int)errCode
{
    if(errCode == 0) {
        [self showMsg:@"Store Block Success!"];
    }
    else {
        [self showMsg:@"Store Block failed!"];
    }
    
}

-(void)getInCrementResult:(unsigned int)errCode
{
    if(errCode == 0) {
        [self showMsg:@"Increment Success!"];
    }
    else {
        [self showMsg:@"Increment failed!"];
    }
}

-(void)getDecrementResult:(unsigned int)errCode
{
    if(errCode == 0) {
        [self showMsg:@"Decrement Success!"];
    }
    else {
        [self showMsg:@"Decrement failed!"];
    }
}

-(void)getReadValueResult:(unsigned int)errCode retdata:(unsigned char *)retData retLen:(unsigned int)retLen
{
    unsigned int valueAmount;
    
    
    if(errCode == 0) {
        
        valueAmount = retData[0] + (retData[1] << 8) + (retData[2] << 16) + (retData[3] << 24);
        
        self.valueAmountTF.text = [NSString stringWithFormat:@"%d", valueAmount];
        [self showMsg:@"Read Value Success!"];
    }
    else {
        [self showMsg:@"Read Value Failed!"];
    }
    
}

-(void) leaveView{
    
    [self.vcMifareCardDelegate FTaR530DidDisconnected];
}

#pragma mark --FTaR520Delegate Methods--
-(void)FTaR530DidDisconnected{
    NSLog(@"M V disconnect") ;
    
    if (self.vcMifareCardDelegate != nil) {
        [_ar530 setDeviceEventDelegate:self.vcMifareCardDelegate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:^{
            [self performSelector:@selector(leaveView) withObject:nil afterDelay:0.1];
        }];
    });
}

-(void)FTNFCDidComplete:(nfc_card_t)cardHandle retData:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)funcNum errCode:(unsigned int)errCode
{
    NSLog(@"\nfunctionNum:%d\nerrCode:%08x\n", funcNum, errCode);
    
    switch (funcNum) {
        case FT_FUNCTION_NUM_INIT_BLOCK:
            [self getinitBlockResult:errCode];
            break;
            
        case FT_FUNCTION_NUM_STORE_BLOCK:
            [self getStoreBlockResult:errCode];
            break;
            
        case FT_FUNCTION_NUM_INCREMENT:
            [self getInCrementResult:errCode];
            break;
            
        case FT_FUNCTION_NUM_DECREMENT:
            [self getDecrementResult:errCode];
            break;
            
        case FT_FUNCTION_NUM_READ_VALUE:
            [self getReadValueResult:errCode retdata:retData retLen:retDataLen];
            break;
            
        default:
            break;
    }
}

@end
