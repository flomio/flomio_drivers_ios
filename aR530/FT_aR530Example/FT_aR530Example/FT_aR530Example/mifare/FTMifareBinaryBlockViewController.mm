//
//  FTMifareBinaryBlockViewController.m
//  FTCRa520Test
//
//  Created by Li Yuelei on 7/16/13.
//  Copyright (c) 2013 FT. All rights reserved.
//

#import "FTMifareBinaryBlockViewController.h"
#import "../include/utils.h"

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

@interface FTMifareBinaryBlockViewController ()

@end

@implementation FTMifareBinaryBlockViewController
@synthesize sectNOTF;
@synthesize blockNoTF;
@synthesize lengthTF;
@synthesize dataTF;

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
    
    UILabel *secNOLB = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 140, 30)];
    secNOLB.text = @"Section No:";
    secNOLB.textAlignment = UITextAlignmentRight;
    secNOLB.backgroundColor = [UIColor clearColor];
    [self.view addSubview:secNOLB];
    
    sectNOTF = [[UITextField alloc] initWithFrame:CGRectMake(160, 20, 150, 30)];
    sectNOTF.delegate = self;
    sectNOTF.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:sectNOTF];
    
    UILabel *blockNoLB = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 140, 30)];
    blockNoLB.text = @"Block No:";
    blockNoLB.textAlignment = UITextAlignmentRight;
    blockNoLB.backgroundColor = [UIColor clearColor];
    [self.view addSubview:blockNoLB];
    
    blockNoTF = [[UITextField alloc] initWithFrame:CGRectMake(160, 60, 150, 30)];
    blockNoTF.borderStyle = UITextBorderStyleRoundedRect;
    blockNoTF.delegate = self;
    [self.view addSubview:blockNoTF];
    
    UILabel *lengthLB = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 140, 30)];
    lengthLB.text = @"length:";
    lengthLB.textAlignment = UITextAlignmentRight;
    lengthLB.backgroundColor = [UIColor clearColor];
    [self.view addSubview:lengthLB];
    
    lengthTF = [[UITextField alloc] initWithFrame:CGRectMake(160, 100, 150, 30)];
    lengthTF.borderStyle = UITextBorderStyleRoundedRect;
    lengthTF.delegate = self;
    [self.view addSubview:lengthTF];
    
    UILabel *dataLB = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 140, 30)];
    dataLB.text = @"Data(text):";
    dataLB.textAlignment = UITextAlignmentRight;
    dataLB.backgroundColor = [UIColor clearColor];
    [self.view addSubview:dataLB];
        
    dataTF = [[UITextField alloc] initWithFrame:CGRectMake(160, 140, 150, 30)];
    dataTF.borderStyle = UITextBorderStyleRoundedRect;
    dataTF.delegate = self;
    [self.view addSubview:dataTF];
    
    [self drawLine:self.view rect:CGRectMake(10, 180, 300, 2)];
    
    UIButton *readBlockBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    readBlockBtn.frame = CGRectMake(80, 200, 150, 30);
    [readBlockBtn setTitle:@"Read Block" forState:UIControlStateNormal];
    [readBlockBtn addTarget:self action:@selector(readBlockFun) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readBlockBtn];
    
    UIButton *updateBlockBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    updateBlockBtn.frame = CGRectMake(80, 240, 150, 30);
    [updateBlockBtn setTitle:@"Update Block" forState:UIControlStateNormal];
    [updateBlockBtn addTarget:self action:@selector(updateBlockFun) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateBlockBtn];
    
    [self drawLine:self.view rect:CGRectMake(10, 280, 300, 2)];
    
    UIButton *retBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    retBtn.frame = CGRectMake(10, 300, 300, 30);
    [retBtn setTitle:@"return to Mifare View" forState:UIControlStateNormal];
    [retBtn addTarget:self action:@selector(returnToMifareView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:retBtn];
}

-(void)showMsg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"用户提示" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(unsigned short)calculateBlockNo:(unsigned short)section BlockNumber:(unsigned short)block
{
    return section * 4 + block;
}

-(void)updateBlockFun
{    
    unsigned short section = [[sectNOTF text] intValue];
    unsigned short block = [[blockNoTF text] intValue];
    unsigned char length = 0;
    unsigned char data[256] = {0};
    
    unsigned short blockNo = [self calculateBlockNo:section BlockNumber:block];
    
    const char *data_str = [[dataTF text] UTF8String];
    
    length = strlen(data_str) / 2;
    
    StrToHex(data, (char *)data_str, strlen(data_str));
    
    [FTaR530 mifare_UpdateBinary:NFC_Card blockNum:blockNo data:data size:length delegate:self];
}

-(void)getUpdateBlockResult:(unsigned int)errCode
{
    if(errCode == 0) {
        [self showMsg:@"Update Binary Success!"];
    }else {
        [self showMsg:[NSString stringWithFormat:@"Update Binary Failed!(Error Code:%02x)", errCode]];
    }

}

-(void)readBlockFun
{
    
    
    unsigned short block = [[blockNoTF text] intValue];
    unsigned char length = [[lengthTF text] intValue];
    unsigned short Section = [[sectNOTF text] intValue];

    unsigned short blockNo = [self calculateBlockNo:Section BlockNumber:block];
    
    [FTaR530 Mifare_ReadBinary:NFC_Card blockNum:blockNo size:length delegate:self];
    
}

-(void)getReadBlockResult:(unsigned int)errCode retData:(unsigned char *)retData retLen:(unsigned int)retLen
{
    
    char data_str[256] = {0};
    
    if(errCode == 0) {
        HexToStr(data_str, retData, retLen);
        [self showMsg:[NSString stringWithFormat:@"Read Binary Success!(Data:%s)",data_str]];
    }else {
        [self showMsg:[NSString stringWithFormat:@"Read Binary Failed!(Error code:%02x)",errCode]];
    }
}

extern bool isShowBinaryBlockView;

-(void)returnToMifareView
{
    isShowBinaryBlockView = false;
    [self dismissModalViewControllerAnimated:YES];
}

-(void)dismissSelfView
{
    isShowBinaryBlockView = false;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark --FTaR520Delegate Methods--
-(void)FTNFCDidComplete:(nfc_card_t)cardHandle retData:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)funcNum errCode:(unsigned int)errCode
{
    NSLog(@"\nfuncitonNum:%d\nerrCode:%d\n", funcNum, errCode);
    
    switch (funcNum) {
        case FT_FUNCTION_NUM_READ_BINARY:
            [self getReadBlockResult:errCode retData:retData retLen:retDataLen];
            break;
        case FT_FUNCTION_NUM_UPDATE_BINARY:
            [self getUpdateBlockResult:errCode];
            break;
        default:
            break;
    }
}

@end
