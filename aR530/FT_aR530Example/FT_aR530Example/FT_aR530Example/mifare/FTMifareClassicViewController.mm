//
//  FTMifareClassicViewController.m
//  FTCRa520Test
//
//  Created by Li Yuelei on 7/11/13.
//  Copyright (c) 2013 FT. All rights reserved.
//

#import "FTMifareClassicViewController.h"
#import "FTmifareValueBlockViewController.h"
#import "FTMifareBinaryBlockViewController.h"
#import "utils.h"

#ifdef __IPHONE_6_0 // iOS6 and later
#   define UITextAlignmentCenter            NSTextAlignmentCenter
#   define UITextAlignmentLeft              NSTextAlignmentLeft
#   define UITextAlignmentRight             NSTextAlignmentRight
#   define UILineBreakModeTailTruncation    NSLineBreakByTruncatingTail
#   define UILineBreakModeMiddleTruncation  NSLineBreakByTruncatingMiddle
#   define UILineBreakModeWordWrap          NSLineBreakByWordWrapping
#   define UILineBreakModeCharacterWrap     NSLineBreakByCharWrapping
#endif

extern nfc_card_t NFC_Card;

extern bool isShowMifare;

bool isShowValueBlockView = false;
bool isShowBinaryBlockView = false;

FTmifareValueBlockViewController *valueBlockObj = nil;
FTMifareBinaryBlockViewController *binaryBlockObj = nil;

@interface FTMifareClassicViewController ()

@end

@implementation FTMifareClassicViewController
@synthesize retBtn;
@synthesize loadKeysBtn;
@synthesize authenBtn;
@synthesize sectNO_TF;
@synthesize storeNo_TF;
@synthesize keyType_TF;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)drawLine:(UIView *)view rect:(CGRect)rect
{
    UIImageView *image1 = [[UIImageView alloc] initWithFrame:rect];
    image1.backgroundColor = [UIColor grayColor];
    [view addSubview:image1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor lightGrayColor];

    
    UILabel *desfireLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    desfireLabel.text = @"Mifare Classic";
    desfireLabel.textAlignment = UITextAlignmentCenter;
    desfireLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:desfireLabel];
    
    //draw line
    [self drawLine:self.view rect:CGRectMake(10, 40, 300, 2)];
    
    UILabel *secNOLB = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 140, 30)];
    secNOLB.text = @"Section No:";
    secNOLB.textAlignment = UITextAlignmentRight;
    secNOLB.backgroundColor = [UIColor clearColor];
    [self.view addSubview:secNOLB];
    
    sectNO_TF = [[UITextField alloc] initWithFrame:CGRectMake(160, 50, 150, 30)];
    sectNO_TF.delegate = self;
    sectNO_TF.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:sectNO_TF];
    
    UILabel *keyStoreNoLB = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, 140, 30)];
    keyStoreNoLB.text = @"AuthenKey:";
    keyStoreNoLB.textAlignment = UITextAlignmentRight;
    keyStoreNoLB.backgroundColor = [UIColor clearColor];
    [self.view addSubview:keyStoreNoLB];
    
    storeNo_TF = [[UITextField alloc] initWithFrame:CGRectMake(160, 90, 150, 30)];
    storeNo_TF.delegate = self;
    storeNo_TF.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:storeNo_TF];
    
    UILabel *keyTypeLB = [[UILabel alloc] initWithFrame:CGRectMake(10, 130, 140, 30)];
    keyTypeLB.text = @"Key Type:";
    keyTypeLB.textAlignment = UITextAlignmentRight;
    keyTypeLB.backgroundColor = [UIColor clearColor];
    [self.view addSubview:keyTypeLB];
    
    keyType_TF = [[UITextField alloc] initWithFrame:CGRectMake(160, 130, 150, 30)];
    keyType_TF.delegate = self;
    keyType_TF.placeholder = @"'A' or 'B'";
    keyType_TF.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:keyType_TF];
    
    authenBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    authenBtn.frame = CGRectMake(70, 170, 170, 30);
    [authenBtn setTitle:@"Authentication" forState:UIControlStateNormal];
    [authenBtn addTarget:self action:@selector(authenticationFun) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:authenBtn];
    
    //draw line
    [self drawLine:self.view rect:CGRectMake(10, 210, 300, 2)];

    
    UIButton *valueBlockBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    valueBlockBtn.frame = CGRectMake(70, 220, 170, 30);
    [valueBlockBtn setTitle:@"Value Block Functions" forState:UIControlStateNormal];
    [valueBlockBtn addTarget:self action:@selector(changeToValueBlockView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:valueBlockBtn];
    
    UIButton *BinaryBlockBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    BinaryBlockBtn.frame = CGRectMake(70, 260, 170, 30);
    [BinaryBlockBtn setTitle:@"Binary Block Functions" forState:UIControlStateNormal];
    [BinaryBlockBtn addTarget:self action:@selector(BinaryBlockFuns) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:BinaryBlockBtn];
    
    [self drawLine:self.view rect:CGRectMake(10, 300, 300, 2)];
    
    retBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    retBtn.frame = CGRectMake(10, 320, 300, 30);
    [retBtn setTitle:@"return to Main ViewController" forState:UIControlStateNormal];
    [retBtn addTarget:self action:@selector(retFun) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:retBtn];
        
}

-(void)BinaryBlockFuns
{
    binaryBlockObj = [[FTMifareBinaryBlockViewController alloc] init];
    [self presentModalViewController:binaryBlockObj animated:YES];
    isShowBinaryBlockView = true;
}

-(void)showMsg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"用户提示" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)retFun
{
    isShowMifare = false;
    [self dismissModalViewControllerAnimated:YES];
}

-(void)changeToValueBlockView
{
    if(valueBlockObj == nil) {
        valueBlockObj = [[FTmifareValueBlockViewController alloc] init];
    }
    [self presentModalViewController:valueBlockObj animated:YES];
    isShowValueBlockView = true;
}

-(void)authenticationFun
{    
    WORD sectionNO = [[sectNO_TF text] intValue];
    WORD blocksNo = sectionNO * 4;
    BYTE keyType;
    BYTE authenKey[6] = {0};
    
    const char *key_str = [[storeNo_TF text] UTF8String];
    
    if([[storeNo_TF text] length] == 0) {
        [self getAuthenResult:1];
        return;
    }
    
    StrToHex(authenKey, (char *)key_str, 12);
    
    if([[keyType_TF text] isEqualToString:@"A"] || [[keyType_TF text] isEqualToString:@"a"]) {
        keyType = 0x60;
    }else {
        keyType = 0x61;
    }
    
    [FTaR530 Mifare_GeneralAuthenticate:NFC_Card blockNum:blocksNo keyType:keyType key:authenKey delegate:self];
    

}

-(void)getAuthenResult:(unsigned int)errCode
{
    if(errCode == 0) {
        [self showMsg:@"Authentication Success"];
    }else {
        [self showMsg:@"Authentication Failed"];
    }
}

-(void)dismissMySelfView
{
    if(isShowValueBlockView == true) {
        [valueBlockObj dismissSelfView];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hideSelfView) userInfo:nil repeats:NO];
    }else if(isShowBinaryBlockView == true) {
        [binaryBlockObj dismissSelfView];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hideSelfView) userInfo:nil repeats:NO];
    }else {
        [self hideSelfView];
    }
    
    
}

-(void)hideSelfView
{
    isShowMifare = false;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --UITextFieldDelegate Methods--
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark --FTaR520Delegate Methods--
-(void)FTNFCDidComplete:(nfc_card_t)cardHandle retData:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)funcNum errCode:(unsigned int)errCode
{

    NSLog(@"\nfunctionNum:%d\nerrCode:%d\n", funcNum, errCode);
    switch (funcNum) {
        case FT_FUNCTION_NUM_AUTHENTICATE:
            [self getAuthenResult:errCode];
            break;
            
        default:
            break;
    }
}

@end
