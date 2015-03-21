//
//  OadScreenViewController.m
//  FloJack
//
//  Created by Chuck Carter on 3/14/15.
//  Copyright (c) 2015 John Bullard. All rights reserved.
//

#import "OadScreenViewController.h"

@interface OadScreenViewController ()
{
NSInteger totalBytes;
NSInteger sentBytes;
CGFloat sentTime;
OadFile * oadFile;
NSString * updateButtonTitleIsCancel;
NSString * updateButtonTitleIsUpdate;
}
@property (strong, nonatomic) OadFile * oadFile;
@property (strong, nonatomic) NSString * updateButtonTitleIsCancel;
@property (strong, nonatomic) NSString * updateButtonTitleIsUpdate;
@property (assign, nonatomic) NSInteger totalBytes;
@property (assign, nonatomic) NSInteger sentBytes;
@property (assign, nonatomic) CGFloat sentTime;

@end

@implementation OadScreenViewController
@synthesize appDelegate                     = _appDelegate;
@synthesize UpdateProgressBar   = _UpdateProgressBar;
@synthesize BytesStatus         = _BytesStatus;
@synthesize BytesPerSecStatus   = _BytesPerSecStatus;
@synthesize oadFile             = _oadFile;
@synthesize updateButtonTitleIsCancel = _updateButtonTitleIsCancel;
@synthesize updateButtonTitleIsUpdate = _updateButtonTitleIsUpdate;
@synthesize delegate;
@synthesize totalBytes;
@synthesize sentBytes;
@synthesize sentTime;


- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *) UIApplication.sharedApplication.delegate;
    [self setOadFile:_appDelegate.oadFile];
//    NSLog(@"viewDidLoad");
    if([oadFile isConnected]) [oadFile requestCurrentImageType];
    [oadFile resetOadUploadAttributes];
    [self.oadFile setCanceled:NO];
    [UpdateButtonIBOutlet setEnabled:NO];
    sentBytes = 0;
    totalBytes = 0;
    sentBytes = 0;
    sentTime = 0;
    
    updateButtonTitleIsCancel = @"Cancel";
    updateButtonTitleIsUpdate = @"Update";
    [UpdateButtonIBOutlet setTitle:updateButtonTitleIsUpdate forState:normal];


    [self updateAllFields];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    /​/​ ​C​l​e​a​r​ ​f​i​r​s​t​ ​r​e​s​p​o​n​d​e​r
    [self.view endEditing:YES];
    
    [self.oadFile setCanceled:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _appDelegate = (AppDelegate *) UIApplication.sharedApplication.delegate;
    [self setOadFile:_appDelegate.oadFile];
//    NSLog(@"viewDidAppear");
    if([oadFile isConnected]) [oadFile requestCurrentImageType];
    [oadFile resetOadUploadAttributes];
    [self.oadFile setCanceled:NO];

    [UpdateButtonIBOutlet setEnabled:NO];
    [UpdateButtonIBOutlet setTitle:updateButtonTitleIsUpdate forState:normal];
    sentBytes = 0;
    sentBytes = 0;
    totalBytes = 0;
    sentBytes = 0;
    sentTime = 0;

    [self updateAllFields];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)UpdateButton:(id)sender
{
    NSString * imageTypeError;
    
    if(![oadFile isConnected])
    {
        imageTypeError = @"Need to connect the device.";
        [self showAlertWithTitle:@"BLE Connection Error" andMessage:imageTypeError];
        return;
    }
    
    if ([oadFile validateImageTypes])
    {

        if ([UpdateButtonIBOutlet currentTitle] == updateButtonTitleIsCancel)
        {
            [UpdateButtonIBOutlet setTitle:updateButtonTitleIsUpdate forState:normal];
            [oadFile setCanceled:YES];

            [oadFile setIsUploadInProgress:NO];
        }
        else
        {
            [UpdateButtonIBOutlet setTitle:updateButtonTitleIsCancel forState:normal];
            [oadFile setCanceled:NO];
            [oadFile setIsUploadInProgress:YES];
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(flashWindowUpdateTimerTick:) userInfo:nil repeats:NO];
            [self setSentTime:0];
            [self.appDelegate updateButtonPress];
        }
    }
    else
    {
        NSLog(@"inValidImageType");

        [UpdateButtonIBOutlet setTitle:updateButtonTitleIsUpdate forState:normal];
        [oadFile setCanceled:NO];
        [oadFile setIsUploadInProgress:NO];
        if([oadFile currentImageType] == imageAtype)
        {
            imageTypeError = @"Need to select a Type B image";
        }
        else
        {
            imageTypeError = @"Need to select a Type A image";
        }
        [self showAlertWithTitle:@"Error in file types..." andMessage:imageTypeError];
    }

}

- (IBAction)FileNameEditAction:(id)sender
{

    [self.view endEditing:YES];

}

- (IBAction)UploadFileSet:(id)sender
{
    NSDataReadingOptions readingOptions = NSDataReadingUncached;
    //    NSError * errorPtr;
    [_appDelegate.oadFile setOadData:nil];
    [_appDelegate.oadFile setOadDataLength:0];
    
    NSString * fileName = [self FileName].text;
    NSLog(@"fileName %@",fileName);
    NSRange theRange = [fileName rangeOfString:@".bin" options:NSBackwardsSearch];
    if (theRange.location == NSNotFound)
    {
        [self showAlertWithTitle:@"Error in file..." andMessage:@"File must be of type -.bin"];
        return;
    }
    else
    {
        [self.oadFile.oadFileName setString:fileName];
    }
    
//    dispatch_async(dispatch_get_main_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
   dispatch_async(dispatch_get_main_queue(), ^{
        NSError * errorPtr;
       NSData * theData = [NSData dataWithContentsOfURL:[NSURL URLWithString: fileName] options:NSDataReadingUncached error:&errorPtr];
        [_appDelegate.oadFile setOadData:theData];
//        oadFile.oadData = [theData copy];

        NSLog(@"Error %@",errorPtr);
        if(!errorPtr)
        {
            [oadFile extractImageHeader];
            //        [UpdateButtonIBOutlet setEnabled:YES];
            [_appDelegate.oadFile setHasValidFile:YES];
            [self updateUpdateButton];
            
        }
        else
        {
            [oadFile clearImageHeader];
            //        [UpdateButtonIBOutlet setEnabled:NO];
            [oadFile setHasValidFile:NO];
            [self updateUpdateButton];
            NSLog(@"Error opening file... %@",[errorPtr localizedFailureReason]);
            [self showAlertWithTitle:@"Error opening file..." andMessage:[errorPtr localizedFailureReason]];
        }
        if([oadFile isConnected]) [oadFile requestCurrentImageType];
        [oadFile.oadFileName setString:fileName];
        [oadFile setBytesSent:0];
        [self updateFileName:[oadFile oadFileName]]; //[self updateFileName:fileName];
        [self updateUploadImageType:[oadFile oadImageType]];
        [self updateBytesStatus:0];
        [self updateBytes:0 perSec:0];
        [self updateAllFields];
        
        NSLog(@"File Len:%ld CRC0:0x%4.4x  CRC1:0x%4.4x, version:0x%4.4x len:0x%4.4x",(long)[oadFile oadDataLength],[oadFile oadImageHeader].crc0, [oadFile oadImageHeader].crc1,[oadFile oadImageHeader].ver,[oadFile oadImageHeader].len);

    });
    
    [self.view endEditing:YES];
    
    //https://www.dropbox.com/s/049gywdkmsyadqp/OAD_A.bin?dl=0

}

#pragma mark - accessors
- (void) setOadFile:(OadFile *)theOadFile
{
    oadFile = theOadFile;
    //    NSLog(@"setOadFile");
    if([oadFile isConnected]) [oadFile requestCurrentImageType];
    [oadFile resetOadUploadAttributes];
    
    [self updateAllFields];
}

#pragma mark - Updates API
- (void)updateAllFields
{
    [self updateCurrentImageType:[oadFile currentImageType]];
    [self updateUploadImageType:[oadFile oadImageType]];
    [self updateFirmwareVersion:[oadFile currentFirmwareVersion]];
    [self updateFileName:[oadFile oadFileName]];
    [self updateBytesStatus:sentBytes];
    [self updateBytes:sentBytes perSec:sentTime];
    [self updateUpdateButton];
}

- (void)updateUpdateButton
{
    [UpdateButtonIBOutlet setEnabled:[oadFile hasValidFile]];
}

- (void)updateCurrentImageType:(imageType)type
{
    NSString * imageType;
    //    switch (type)
    switch ([oadFile currentImageType])
    {
        case imageAtype:
            imageType = @"A";
            break;
        case imageBtype:
            imageType = @"B";
            break;
        default:
            imageType = @"-";
            break;
    }
    [self CurrentImageTypeText].text = [NSString stringWithFormat:@"Image Type : %@",imageType];
    
}

- (void)updateUploadImageType:(imageType)type
{
    NSString * imageType;
    switch (type)
    {
        case imageAtype:
            imageType = @"A";
            break;
        case imageBtype:
            imageType = @"B";
            break;
        default:
            imageType = @"-";
            break;
    }
    [self UploadImageTypeText].text = [NSString stringWithFormat:@"Image Type : %@",imageType];
    
}

- (void)updateFirmwareVersion:(NSString*)version
{
    [self FirmwareVersion].text = [NSString stringWithFormat:@"Firmware Version : %@",[oadFile currentFirmwareVersion]];
}

- (void)updateFileName:(NSString*)name
{
    //    [oadFileName setString:name];//= name;
    [self FileName].text = [NSString stringWithFormat:@"%@",[oadFile oadFileName]];
}

- (void)updateBytesStatus:(NSInteger)nBytes
{
    sentBytes = [oadFile bytesSent];
    totalBytes = [oadFile bytesToSend];
    [self BytesStatus].text = [NSString stringWithFormat:@"Bytes : %ld/%ld",(long)sentBytes,(long)totalBytes];
    
    double num = sentBytes;
    double dnom = totalBytes;
    double percent;
    
    if (dnom) {
        percent= (num/dnom)*1;
    }
    else
    {
        percent = 0;
    }
    
    [_UpdateProgressBar setProgress:percent];
    //    NSLog(@"updateBytesStatus %ld %f",sentBytes, percent);
    [self setSentTime:[self sentTime]+0.5];
    [self updateBytes:(sentBytes) perSec:[self sentTime]];
}

- (void)updateBytes:(NSInteger)nBytes perSec:(CGFloat)nSecs
{
    if (nSecs)
    {
        CGFloat sentBytesPerSec = (CGFloat)nBytes/nSecs;
        [self BytesPerSecStatus].text = [NSString stringWithFormat:@"BytesPerSec : %0.2f",sentBytesPerSec];
    }
    else
    {
        CGFloat sentBytesPerSec = 0;
        [self BytesPerSecStatus].text = [NSString stringWithFormat:@"BytesPerSec : %0.2f",sentBytesPerSec];
    }
}

#pragma mark - utilities
- (void)cancelUpdate
{
    [UpdateButtonIBOutlet setTitle:updateButtonTitleIsUpdate forState:normal];
    [oadFile setCanceled:YES];
    [oadFile setIsUploadInProgress:NO];
}

- (void)endOfUpdate
{
    [oadFile setBytesSent:0];
    [UpdateButtonIBOutlet setTitle:updateButtonTitleIsUpdate forState:normal];
    [oadFile setCanceled:NO];
    [oadFile setIsUploadInProgress:NO];
    NSLog(@":::endOfUpdate");
    NSString* imageTypeError = @"You will need to reconnect the device after it restarts.";
    [self showAlertWithTitle:@"Upload Complete" andMessage:imageTypeError];
}

#pragma mark - timers
-(void) flashWindowUpdateTimerTick:(NSTimer *)time
{
    if([oadFile isUploadInProgress])
    {
        [self updateBytesStatus:0];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(flashWindowUpdateTimerTick:) userInfo:nil repeats:NO];
    }
    
}

#pragma mark - UI Output

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

@end
