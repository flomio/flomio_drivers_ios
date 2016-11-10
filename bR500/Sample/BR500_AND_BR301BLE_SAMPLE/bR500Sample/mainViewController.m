//
//  mainViewController.m
//  bR500Sample
//
//  Created by 彭珊珊 on 16/1/20.
//  Copyright © 2016年 ftsafe. All rights reserved.
//

#import "mainViewController.h"
#import "hex.h"

@interface mainViewController ()
{
    SCARDCONTEXT gContxtHandle;
    SCARDHANDLE  gCardHandle;
    NSArray *commandList;
    ReaderInterface *readerDescription;
}
@end

#define SoftVersion @"1.8.2"
NSString *identifier = @"commandListView";

@implementation mainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCommandTableView];
    [self createReaderContext];
    [self createButtonItem];
    [self createFileSaveSeedBuffer];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  初始化tableview
 */
-(void)createCommandTableView
{
    //1.初始化UI
    [_commandListView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    commandList = [[NSArray alloc] initWithObjects:@"0084000008",@"0084000004", nil];
}


/**
 *  Create reader context
 */
-(void)createReaderContext
{
    readerDescription = [[ReaderInterface alloc] init];
    [readerDescription setDelegate:self];
    
    SCardEstablishContext(SCARD_SCOPE_SYSTEM,NULL,NULL,&gContxtHandle);
    
    [NSThread detachNewThreadSelector:@selector(getVersionInfo) toTarget:self withObject:nil];
    
}

/**
 *  Get Version 
 */
-(void)getVersionInfo
{
    char firmwareRevision[32]={0};
    char hardwareRevision[32]={0};
    char libVersion[32]={0};
    FtGetLibVersion(libVersion);
    FtGetDevVer(0,firmwareRevision, hardwareRevision);
    
    __block NSString *softVersionString = [NSString stringWithFormat:@"Soft:%@",SoftVersion];
    __block NSString *sdkVersion =  [NSString stringWithFormat:@"SDK:%s",libVersion];
    __block NSString *firmVersionString = [NSString stringWithFormat:@"Firm:%s",firmwareRevision];
    dispatch_async(dispatch_get_main_queue(), ^{
        _softVersion.text = softVersionString;
        _SDKVersion.text = sdkVersion;
        _firmVersion.text = firmVersionString;
    });
}
/**
 *  Add button on navigation bar
 */
-(void)createButtonItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_currentReaderName style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(displayVersionInfo:)];
}

-(void)back:(UIButton*)sender
{
    [readerDescription disConnectCurrentPeripheralReader];
    [self.navigationController popToRootViewControllerAnimated:YES];
   
}

-(void)displayVersionInfo:(UIButton *)sender
{
    NSLog(@"HSSHHSHSH");
}
/**
 *  Create seed code and Flash data file 
 */
-(void)createFileSaveSeedBuffer
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docmentDirectory = [directoryPaths objectAtIndex:0];
    NSString *seedFilePath = [docmentDirectory stringByAppendingPathComponent:@"seed.txt"];
    NSString *flashFilePath = [docmentDirectory stringByAppendingPathComponent:@"flash.txt"];
    //1.Create store seeds code file 
    if (![fileManager fileExistsAtPath:seedFilePath] ) {
        [fileManager createFileAtPath:seedFilePath contents:nil attributes:nil];
    }
    //2.Create flash file
    if (![fileManager fileExistsAtPath:flashFilePath]) {
        [fileManager createFileAtPath:flashFilePath contents:nil attributes:nil];
    }
}


/**
 *  Read contents
 *
 *  @param fileName File name
 *
 *  @return File contents
 */
-(NSData *)readFileContent:(NSString *)fileName
{
    NSData* fileData = nil;
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docmentDirectory = [directoryPaths objectAtIndex:0];
    NSString *filePath = [docmentDirectory stringByAppendingPathComponent:fileName];
    
    fileData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSString *srcString = [[NSString alloc] initWithData:fileData  encoding:NSUTF8StringEncoding];;
    NSString *desString = [srcString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    fileData = [desString dataUsingEncoding:NSUTF8StringEncoding];
    return fileData;
    
}

/**
 *  Power ON to card
 *
 *  @param sender
 */
-(IBAction)connectCard:(id)sender
{
    _atrTextView.text = @"";
    LONG iRet = 0;
    DWORD dwActiveProtocol = -1;
    char mszReaders[128] = "";
    
    if ([_currentReaderName length] != 0) {
        memcpy(mszReaders, _currentReaderName.UTF8String, _currentReaderName.length);
    }

    iRet = SCardConnect(gContxtHandle,mszReaders,SCARD_SHARE_SHARED,SCARD_PROTOCOL_T0 | SCARD_PROTOCOL_T1,&gCardHandle,&dwActiveProtocol);
    if (iRet != 0) {
        _atrTextView.text = @"Connect Card Error.\n";
        _logTextView.text = @"Connect Card Error.\n";
        return;
        
    }else {
        unsigned char patr[33];
        DWORD len = sizeof(patr);
        iRet = SCardGetAttrib(gCardHandle,NULL, patr, &len);
        if(iRet != SCARD_S_SUCCESS)
        {
            NSLog(@"SCardGetAttrib error %08x",iRet);
        }
        
        NSMutableData *tmpData = [NSMutableData data];
        [tmpData appendBytes:patr length:len];
        
        _atrTextView.text = [NSString stringWithFormat:@"ATR:%@",[tmpData description]];
        _logTextView.text = @"Connect Card Success.\n";
        
    }

}
/**
 *  Power OFF 
 *
 *  @param sender 
 */
-(IBAction)disConnectCard:(id)sender
{
    LONG iRet = 0;
    iRet = SCardDisconnect(gCardHandle,SCARD_UNPOWER_CARD);
    if (iRet != 0) {
        _atrTextView.text = @"disConnect Connect Error.";
        _logTextView.text = [_logTextView.text stringByAppendingString:[NSString stringWithFormat:@"PowerOff Error:%08x\n",iRet]];
    }
    else
    {
        _atrTextView.text = @"";
        _logTextView.text = [_logTextView.text stringByAppendingString:@"PowerOff Success\n"];
    }

}

/**
 *  Send data
 *
 *  @param sender
 */
-(IBAction)sendCommand:(id)sender
{
    LONG iRet = 0;
    unsigned  int capdulen;
    unsigned char capdu[2056];
    unsigned char resp[2056];
    unsigned int resplen = sizeof(resp) ;
    
    //1.Judge apdu length 
    if([_apduTextField.text length] < 5  )
    {
        _logTextView.text = [_logTextView.text  stringByAppendingString:@"Invalid APDU.\n"];
        return;
    }

    //2. Convert data format
    NSData *apduData =[hex hexFromString:_apduTextField.text];
    [apduData getBytes:capdu length:apduData.length];
    capdulen = (unsigned int)[apduData length];
    
    //3. Send data
    SCARD_IO_REQUEST pioSendPci;
    iRet=SCardTransmit(gCardHandle,&pioSendPci, (unsigned char*)capdu, capdulen,NULL,resp, &resplen);
     _logTextView.text = [_logTextView.text stringByAppendingString:[NSString stringWithFormat:@"Send:%@\n",_apduTextField.text]];
    if (iRet != 0) {
       
        _logTextView.text = [_logTextView.text stringByAppendingString:[NSString stringWithFormat:@"Rec:%08x\n",iRet]];
        return;
    }
    else {
        
        NSMutableData *RevData = [NSMutableData data];
        [RevData appendBytes:resp length:resplen];
        _logTextView.text = [_logTextView.text stringByAppendingString:[NSString stringWithFormat:@"Rec:%@\n",[RevData description]]];
    }
    

}


-(IBAction)dispostList:(id)sender
{
    if (_commandListView != nil) {
        _commandListView.hidden = !_commandListView.hidden;
    }
}

/**
 *  Write UID
 *
 *  @param sender 
 */
-(IBAction)writeReaderUID:(id)sender
{
    NSData *fileData = [self readFileContent:@"seed.txt"];
    if ([fileData length] == 0) {
        _logTextView.text = @"seed is nil.\n";
        return;
    }
    
    unsigned char seedBuffer[64] = {0};
    unsigned int seedLength = 0;
    LONG iRet = 0;

    seedLength =(unsigned int)fileData.length;
    
    iRet =  filterStr((char *)[fileData bytes], seedLength);
    if (iRet != 0) {
        _logTextView.text = @"the format of seed data error.(0~9 a~f A~F)";
        return;
    }
    
    seedLength = seedLength/2;
    StrToHex(seedBuffer, (char *)[fileData bytes], seedLength);
    
    iRet = FtGenerateDeviceUID(gContxtHandle,seedLength,seedBuffer);
    if(iRet != 0 ){
        _logTextView.text = @"writeUID ERROR.\n";
    }else {
        _logTextView.text = @"writeUID Successful.\n";
    }

}

/**
 *  Read UID
 *
 *  @param sender
 */
-(IBAction)readReaderUID:(id)sender
{
    char buffer[20] = {0};
    unsigned int length = sizeof(buffer);
    LONG iRet = FtGetDeviceUID(gContxtHandle,&length, buffer);
    if(iRet != 0 ){
        _logTextView.text = @"readUID Error.\n";
    }else {
        NSData *temp = [NSData dataWithBytes:buffer length:length];
        _logTextView.text = [NSString stringWithFormat:@"%@\n", temp];
    }

}

/**
 *  Erase reader UID
 *
 *  @param sender
 */
-(IBAction)eraseReaderUID:(id)sender
{
    NSData *fileData = [self readFileContent:@"seed.txt"];
    if ([fileData length] == 0) {
        _logTextView.text = @"seed is nil.\n";
        return;
    }

    unsigned char seedBuffer[64] = {0};
    unsigned int seedLength = 0;
    LONG iRet = 0;
    
    seedLength =(unsigned int)fileData.length;
    iRet =  filterStr((char *)[fileData bytes], seedLength);
    if (iRet != 0) {
        _logTextView.text = @"the format of seed data error.(0~9 a~f A~F)";
        return;
    }
    
    seedLength = seedLength/2;
    StrToHex(seedBuffer, (char *)[fileData bytes], seedLength);

    iRet = FtEraseDeviceUID(gContxtHandle,seedLength,seedBuffer);
    if(iRet != 0 ){
        _logTextView.text = @"eraseUID Error.\n";
    }else {
        _logTextView.text = @"eraseUID Successful.\n";
    }

}

/**
 *  Write FLASH
 *
 *  @param sender
 */
-(IBAction)writeReaderFlash:(id)sender
{
    NSData *fileData = [self readFileContent:@"flash.txt"];
    if ([fileData length] == 0) {
        _logTextView.text = @"flash data is nil.\n";
        return;
    }
    
    unsigned char buffer[1024] = {0};
    unsigned int length = 0;
    LONG iRet = 0;
    
    length = (unsigned int)fileData.length;
   
    iRet =  filterStr((char *)[fileData bytes], length);
    if (iRet != 0) {
        _logTextView.text = @"the format of flash data error.(0~9 a~f A~F)";
        return;
    }
    
    length = length/2;
    StrToHex(buffer, (char *)[fileData bytes], length);
    
    iRet = FtWriteFlash(gContxtHandle,0,length, buffer);
    if(iRet != 0 ){
        _logTextView.text = @"writeFlash ERROR.\n";
    }else {
        _logTextView.text = @"writeFlash Successful.\n";
    }

}

/**
 *  Read FLASH
 *
 *  @param sender
 */
-(IBAction)readReaderFlash:(id)sender
{
    unsigned char buffer[256] = {0};
    unsigned int length = 255;
    LONG iRet = FtReadFlash(gContxtHandle,0,&length, buffer);
    if(iRet != 0 ){
        _logTextView.text = @"readFlash Error.\n";
    }else {
        NSData *temp = [NSData dataWithBytes:buffer length:length];
        _logTextView.text = [NSString stringWithFormat:@"%@\n", temp];
    }
}

/**
 *  GET CARD SLOT STATUS
 *
 *  @param sender
 */
-(IBAction)getCardStatus:(id)sender
{
    DWORD dwState;
    LONG rv = 0;
    rv = SCardStatus(gContxtHandle, NULL, NULL, &dwState, NULL, NULL, NULL );
    if (rv != 0) {
        _logTextView.text = [NSString stringWithFormat:@"SCardStatus return Error %4x\n",rv];
    }
    
    switch (dwState) {
        case SCARD_ABSENT:
            _logTextView.text = @"The card has absent.\n";
            _cardStatus.on = NO;
            break;
        case SCARD_PRESENT:
            _logTextView.text = @"The card has present.\n";
            _cardStatus.on = YES;
            break;
        case SCARD_SWALLOWED:
            _logTextView.text = @"The Card not powered.\n";
            _cardStatus.on = YES;
            break;
            
        default:
            break;
    }

}

/**
 *  READ HID
 *
 *  @param sender 
 */
-(IBAction)getReaderHID:(id)sender
{
    char buffer[20] = {0};
    unsigned int length = sizeof(buffer);
    LONG iRet = FtGetSerialNum(gContxtHandle,&length, buffer);
    if(iRet != 0 ){
        _logTextView.text = @"Get device HID ERROR.\n";
    }else {
        NSData *temp = [NSData dataWithBytes:buffer length:length];
        _logTextView.text = [NSString stringWithFormat:@"%@\n", temp];
    }
}

#pragma mark - ReaderInterfaceDelegate
-(void)cardInterfaceDidDetach:(BOOL)attached
{
    dispatch_async(dispatch_get_main_queue(), ^{
       _cardStatus.on = attached;
    });
    
}
-(void)readerInterfaceDidChange:(BOOL)attached
{
    if (!attached) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}
-(void)findPeripheralReader:(NSString *)readerName
{

}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [commandList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = commandList[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _apduTextField.text = commandList[indexPath.row];
    _commandListView.hidden = YES;
}

#pragma mark - UITextFeild Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {

    if (theTextField == _apduTextField) {
        [_apduTextField resignFirstResponder]; 
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
