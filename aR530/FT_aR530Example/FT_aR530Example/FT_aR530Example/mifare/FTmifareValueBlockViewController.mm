//
//  FTmifareValueBlockViewController.m
//  FTCRa520Test
//
//  Created by Li Yuelei on 7/15/13.
//  Copyright (c) 2013 FT. All rights reserved.
//

#import "FTmifareValueBlockViewController.h"

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

@interface FTmifareValueBlockViewController ()

@end

@implementation FTmifareValueBlockViewController
@synthesize sectNo_TF;
@synthesize blockNO_TF;
@synthesize valueAmountTF;

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
    
    UILabel *ValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 140, 30)];
    ValueLabel.text = @"Value Amount:";
    ValueLabel.textAlignment = UITextAlignmentRight;
    ValueLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:ValueLabel];
    
    valueAmountTF = [[UITextField alloc] initWithFrame:CGRectMake(160, 20, 150, 30)];
    valueAmountTF.borderStyle = UITextBorderStyleRoundedRect;
    valueAmountTF.delegate = self;
    [self.view addSubview:valueAmountTF];
    
    UILabel *sectionLB = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 140, 30)];
    sectionLB.text = @"Section No:";
    sectionLB.textAlignment = UITextAlignmentRight;
    sectionLB.backgroundColor = [UIColor clearColor];
    [self.view addSubview:sectionLB];
    
    sectNo_TF = [[UITextField alloc] initWithFrame:CGRectMake(160, 60, 150, 30)];
    sectNo_TF.borderStyle = UITextBorderStyleRoundedRect;
    sectNo_TF.delegate = self;
    [self.view addSubview:sectNo_TF];
    
    UILabel *blockNoLB = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 140, 30)];
    blockNoLB.textAlignment = UITextAlignmentRight;
    blockNoLB.backgroundColor = [UIColor clearColor];
    blockNoLB.text = @"Block No:";
    [self.view addSubview:blockNoLB];
    
    blockNO_TF = [[UITextField alloc] initWithFrame:CGRectMake(160, 100, 150, 30)];
    blockNO_TF.borderStyle = UITextBorderStyleRoundedRect;
    blockNO_TF.delegate = self;
    [self.view addSubview:blockNO_TF];
    
    [self drawLine:self.view rect:CGRectMake(10, 150, 300, 2)];
    
    UIButton *initialBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    initialBtn.frame = CGRectMake(80, 170, 150, 30);
    [initialBtn setTitle:@"Initial Block" forState:UIControlStateNormal];
    [initialBtn addTarget:self action:@selector(initialBlockFun) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:initialBtn];
    
    UIButton *ValueAmountBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ValueAmountBtn.frame = CGRectMake(10, 210, 140, 30);
    [ValueAmountBtn setTitle:@"Store Value" forState:UIControlStateNormal];
    [ValueAmountBtn addTarget:self action:@selector(StoreValueFun) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ValueAmountBtn];
    
    UIButton *IncrementBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    IncrementBtn.frame = CGRectMake(160, 210, 140,30);
    [IncrementBtn setTitle:@"Increment" forState:UIControlStateNormal];
    [IncrementBtn addTarget:self action:@selector(incrementFun) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:IncrementBtn];
    
    UIButton *DecrementBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    DecrementBtn.frame = CGRectMake(10, 250, 140, 30);
    [DecrementBtn setTitle:@"Decrement" forState:UIControlStateNormal];
    [DecrementBtn addTarget:self action:@selector(DecrementFun) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:DecrementBtn];
    
    UIButton *ReadValueBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ReadValueBtn.frame = CGRectMake(160, 250, 140, 30);
    [ReadValueBtn setTitle:@"Read Value" forState:UIControlStateNormal];
    [ReadValueBtn addTarget:self action:@selector(readValueFun) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ReadValueBtn];
    
    [self drawLine:self.view rect:CGRectMake(10, 290, 300, 2)];
    
    UIButton *retBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    retBtn.frame = CGRectMake(10, 310, 300, 30);
    [retBtn setTitle:@"return to Mifare View" forState:UIControlStateNormal];
    [retBtn addTarget:self action:@selector(returnToMifare) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:retBtn];
    
}

-(unsigned short)calculateBlockNo:(unsigned short)section BlockNumber:(unsigned short)block
{
    return section * 4 + block;
}

-(void)initialBlockFun
{
    
    unsigned char section = [[sectNo_TF text] intValue];
    unsigned char block = [[blockNO_TF text] intValue];
    
    unsigned char blockNo = [self calculateBlockNo:section BlockNumber:block];
    
    [FTaR530 Mifare_ClassicBlockInitial:NFC_Card blockNum:blockNo delegate:self];
}

-(void)getinitBlockResult:(unsigned int)errCode
{
    
    if(errCode == 0) {
        [self showMsg:[NSString stringWithFormat:@"Block initial Success!"]];
    }else {
        [self showMsg:[NSString stringWithFormat:@"Block initial failed!"]];
    }
}

-(void)showMsg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"用户提示" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)StoreValueFun
{
    
    BYTE section = [[sectNo_TF text] intValue];
    BYTE block = [[blockNO_TF text] intValue];
    
    unsigned char blockNo = [self calculateBlockNo:section BlockNumber:block];
    
    unsigned int valueAmount = [[valueAmountTF text] intValue];
  
    [FTaR530 Mifare_ClassicStoreBlock:NFC_Card blockNum:blockNo valueAmount:valueAmount delegate:self];
    

}

-(void)getStoreBlockResult:(unsigned int)errCode
{
    if(errCode == 0) {
        [self showMsg:@"Store Block Success!"];
    }else {
        [self showMsg:@"Store Block failed!"];
    }

}

-(void)incrementFun
{    
    BYTE section = [[sectNo_TF text] intValue];
    BYTE block = [[blockNO_TF text] intValue];
    
    unsigned char blockNo = [self calculateBlockNo:section BlockNumber:block];
    
    unsigned int valueAmount = [[valueAmountTF text] intValue];
    
    [FTaR530 Mifare_ClassicIncrement:NFC_Card blockNum:blockNo valueAmount:valueAmount delegate:self];
    
}

-(void)getInCrementResult:(unsigned int)errCode
{
    if(errCode == 0) {
        [self showMsg:@"Increment Success!"];
    }else {
        [self showMsg:@"Increment failed!"];
    }
}

-(void)DecrementFun
{    
    BYTE section = [[sectNo_TF text] intValue];
    BYTE block = [[blockNO_TF text] intValue];
    
    unsigned char blockNo = [self calculateBlockNo:section BlockNumber:block];
    
    unsigned int valueAmount = [[valueAmountTF text] intValue];
    
    [FTaR530 Mifare_ClassicDecrement:NFC_Card blockNum:blockNo valueAmount:valueAmount delegate:self];
   
}

-(void)getDecrementResult:(unsigned int)errCode
{
    if(errCode == 0) {
        [self showMsg:@"Decrement Success!"];
    }else {
        [self showMsg:@"Decrement failed!"];
    }
}

-(void)readValueFun
{    
    BYTE section = [[sectNo_TF text] intValue];
    BYTE block = [[blockNO_TF text] intValue];
    
    unsigned char blockNo = [self calculateBlockNo:section BlockNumber:block];
    
    [FTaR530 Mifare_ClassicReadValue:NFC_Card blockNum:blockNo delegate:self];
}

-(void)getReadValueResult:(unsigned int)errCode retdata:(unsigned char *)retData retLen:(unsigned int)retLen
{
    unsigned int valueAmount;
    
    
    if(errCode == 0) {
        
        valueAmount = retData[0] + (retData[1] << 8) + (retData[2] << 16) + (retData[3] << 24);
        
        valueAmountTF.text = [NSString stringWithFormat:@"%d", valueAmount];
        [self showMsg:@"Read Value Success!"];
    }else {
        [self showMsg:@"Read Value Failed!"];
    }

}

extern bool isShowValueBlockView;

-(void)returnToMifare
{
    isShowValueBlockView = false;
    [self dismissModalViewControllerAnimated:YES];
}

-(void)dismissSelfView
{
    isShowValueBlockView = false;
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
    NSLog(@"\nfunctionNum:%d\nerrCode:%d\n", funcNum, errCode);
    
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
