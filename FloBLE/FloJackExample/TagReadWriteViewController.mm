//
//  TagReadWriteViewController.m
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import "TagReadWriteViewController.h"

@interface TagReadWriteViewController ()
{
    NSString *_scanSoundPath;
    NSNotificationCenter * deviceStateNotification;
    NSArray * ledPickerData;
    NSUInteger ledPickedValue;
    NSArray * tagTypeStrings;
}

@property (strong, nonatomic)NSString *_scanSoundPath;
@property (strong, nonatomic)NSNotificationCenter * deviceStateNotification;
@property (strong, nonatomic)NSArray * ledPickerData;
@property (assign)NSUInteger ledPickedValue;
@property (strong, nonatomic) NSArray * tagTypeStrings;


- (void) handleDeviceStateNotification:(NSNotification*)note;

@end

@implementation TagReadWriteViewController

@synthesize appDelegate                     = _appDelegate;
@synthesize outputTextView                  = _outputTextView;
@synthesize pollingRateTextField            = _pollingRateTextField;
@synthesize scrollView                      = _scrollView;
@synthesize statusErrorCount                = _statusErrorCount;
@synthesize statusErrorTextView             = _statusErrorTextView;
@synthesize statusNACKCount                 = _statusNACKCount;
@synthesize statusNACKTextView              = _statusNACKTextView;
@synthesize statusPingPongCount             = _statusPingPongCount;
@synthesize statusPingPongTextView          = _statusPingPongTextView;
@synthesize statusVolumeLowErrorTextView    = _statusVolumeLowErrorTextView;
@synthesize urlInputField                   = _urlInputField;
@synthesize tweakThresholdTextField         = _tweakThresholdTextField;
@synthesize maxThresholdTextField           = _maxThresholdTextField;
@synthesize switchPolling14443A             = _switchPolling14443A;
@synthesize switchPolling15693              = _switchPolling15693;
@synthesize switchPollingFelica             = _switchPollingFelica;
@synthesize switchStandaloneMode            = _switchStandaloneMode;
@synthesize connectionStatusTextField       = _connectionStatusTextField;
@synthesize ledPicker                       = _ledPicker;
@synthesize ledPickerData                   = _ledPickerData;
@synthesize ledPickedValue                  = _ledPickedValue;
@synthesize tagTypeStrings                  = _tagTypeStrings;;
@synthesize oadScreenViewController         = _oadScreenViewController;

#pragma mark - UI View Controller


- (void)viewDidLoad
{
    [super viewDidLoad];
    _statusPingPongCount = 0;
    _statusNACKCount = 0;
    _statusErrorCount = 0;
    _scrollView.contentSize = CGSizeMake(320, 1000);
    _appDelegate = (AppDelegate *) UIApplication.sharedApplication.delegate;
    
    [self connectionStatusTextField].text = [NSString stringWithFormat:@"Off"];

    deviceStateNotification = [NSNotificationCenter defaultCenter];
    [deviceStateNotification addObserver:self selector:@selector(handleDeviceStateNotification:) name:floReaderConnectionStatusChangeNotification object:nil];
    
    // init ledPicker data from floble LED States
/*    typedef enum {
        LED_POWER_UP,
        LED_SLOW_SNIFF,
        LED_ADVERTISING,
        LED_FAST_SNIFF,
        LED_SCANNING_TAG,
        LED_VERIFING_TAG,
        LED_TAG_SUCCESS,
        LED_TAG_ERROR,
        LED_OFF
    } ledStatus_t; */

    _ledPickerData = @[@"LED_POWER_UP 0",@"LED_SLOW_SNIFF 1",@"LED_ADVERTISING 2",@"LED_FAST_SNIFF 3",@"LED_SCANNING_TAG 4",@"LED_VERIFING_TAG 5",@"LED_TAG_SUCCESS 6",@"LED_TAG_ERROR 7",@"LED_OFF 8"];
    self.ledPicker.dataSource = self;
    self.ledPicker.delegate = self;
    [self.ledPicker selectRow:0 inComponent:0 animated:NO];
    ledPickedValue = 0;
    
    [self.view bringSubviewToFront:_ledPicker];
    _ledPicker.hidden = YES;

//    [_consoleTextView insertText:[NSString stringWithFormat:@"FloBLE OSX\n"]];
    [self updateLogTextViewWithString:@"FloBLE IOS [alpha 0.8]\n"];
//    NSString *textUpdate = [NSString stringWithFormat:@":::FloBLE Hardware Version %@", theVersionNumber];
//    [self updateLogTextViewWithString:textUpdate];

    tagTypeStrings = @[@"UNKNOWN_TAG_TYPE", @"NFC_FORUM_TYPE_1", @"NFC_FORUM_TYPE_2", @"NFC_FORUM_TYPE_3", @"NFC_FORUM_TYPE_4", @"MIFARE_CLASSIC",@"TYPE_V"];  // this needs to equal the enum nfc_tag_types_t in floble.

}

#pragma mark - ledPicker
// the number of columns in ledPicker
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// the number of rows in ledPicker
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
//    NSLog(@"ledPicker row count %d", _ledPickerData.count);

    return _ledPickerData.count;
}

// the data to be returned in the rows and columns in the ledPicker
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _ledPickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.ledPicker selectRow:row inComponent:component animated:NO];
    [self.view bringSubviewToFront:_ledPicker];
    _ledPicker.hidden = YES;
    
    _ledPickedValue = row;
    [_ledConfigTextField setText:[NSString stringWithFormat:@"%lu",(unsigned long)_ledPickedValue]];

    NSLog(@"ledPicker picked %ld", (long)row);
}

- (IBAction)ledPickerButtonWasPressed:(id)sender
{
    _ledPicker.hidden = NO;
//    NSLog(@"Show Picker");
    //    [_ledPicker setHidden:NO];

}

- (IBAction)disconnectButton:(id)sender
{
    NSLog(@"disconnectButton");
    [_appDelegate.floReaderManager disconnectDevice];

}

#pragma mark - UI Input
#if 0
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [_appDelegate.floReaderManager setDeviceHasVolumeCap:true];
        [self updateLogTextViewWithString:[NSString stringWithFormat:@":::Device Volume Cap = True"]];
    }
    else {
        [_appDelegate.floReaderManager setDeviceHasVolumeCap:false];
        [self updateLogTextViewWithString:[NSString stringWithFormat:@":::Device Volume Cap = False"]];
    }
}
#endif
// TODO Need to clean up button action because the self.pollingRateTextField "Send" keyboard action
// is a duplicate of this
- (IBAction)buttonWasPressedForPollingRate:(id)sender {
    int pollValue = [self.pollingRateTextField.text intValue];
    _appDelegate.floReaderManager.pollPeriod = pollValue;
    
    [self.view endEditing:YES];
}

- (IBAction)buttonWasPressedForReadTag:(id)sender {
    switch (((UIButton *)sender).tag) {
        case 1:
            [_appDelegate.floReaderManager setModeReadTagUID];
            break;
        case 2:
            [_appDelegate.floReaderManager setModeReadTagUIDAndNDEF];
            break;
        case 3:
            [_appDelegate.floReaderManager setModeReadTagData];
            break;
    }
}

- (IBAction)buttonWasPressedForUtilities:(id)sender
    {

    switch (((UIButton *)sender).tag) {
        case 1:
           // [_appDelegate.floReaderManager initializeFloJackDevice];
            
//            [delegate FirmwareUpdate];
            self.oadScreenViewController = [[OadScreenViewController alloc] initWithNibName:@"OadScreenViewController" bundle:nil];
            [self.navigationController pushViewController:self.oadScreenViewController animated:YES];
            break;
        case 2:
            [_appDelegate.floReaderManager getFirmwareVersion];
            break;
        case 3:
            [_appDelegate.floReaderManager getHardwareVersion];
            break;
        case 4:
            [_appDelegate.floReaderManager getSnifferCalib];
            break;
        case 5:
            // TODO Need to clean up button action because the self.tweakThresholdTextField "Send" keyboard action
            // is a duplicate of this
            [_appDelegate.floReaderManager setIncrementSnifferThreshold:[self.tweakThresholdTextField.text intValue]];
            [self.view endEditing:YES];
            break;
        case 6:
            [_appDelegate.floReaderManager setDecrementSnifferThreshold:[self.tweakThresholdTextField.text intValue]];
            [self.view endEditing:YES];
            break;
        case 7:
            // TODO Need to clean up button action because the self.maxThresholdTextField "Send" keyboard action
            // is a duplicate of this
            [_appDelegate.floReaderManager setMaxSnifferThreshold:[self.maxThresholdTextField.text intValue]];
            [self.view endEditing:YES];
            break;
        case 8:
            [_appDelegate.floReaderManager sendResetSnifferThreshold];
            break;
        case 9:
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EU Mode" message:@"Warning: May damage the FloJack device. Only enable for volume limited devices. See http://flomio.com/volume-limit" delegate:self cancelButtonTitle:@"Enable" otherButtonTitles:@"Cancel", nil];
            [alert show];
            break;
            
    }
}

- (IBAction)buttonWasPressedForLEDConfig:(id)sender
{
//    [_appDelegate.floReaderManager setLedMode:[self.ledConfigTextField.text intValue]];
//    [self.view endEditing:YES];

    [_appDelegate.floReaderManager setLedMode:_ledPickedValue];
}

// TODO Need to clean up button action because the _urlInputField "Send" keyboard action
// is a duplicate of this
- (IBAction)buttonWasPressedForWriteTag:(id)sender {
    NDEFMessage *testMessage = [NDEFMessage createURIWithString:_urlInputField.text];
    [_appDelegate.floReaderManager setModeWriteTagWithNdefMessage:testMessage];
    [self.view endEditing:YES];
}

- (IBAction)switchWasFlippedForConfig:(id)sender {
    UISwitch *onOffSwitch = (UISwitch *) sender;
    switch (onOffSwitch.tag) {
        case 1:
            _appDelegate.floReaderManager.pollFor14443aTags = onOffSwitch.on;
            break;
        case 2:
            _appDelegate.floReaderManager.pollFor15693Tags = onOffSwitch.on;
            break;
        case 3:
            _appDelegate.floReaderManager.pollForFelicaTags = onOffSwitch.on;
            break;
        case 4:
            _appDelegate.floReaderManager.standaloneMode = onOffSwitch.on;
            break;
    }
}

- (IBAction)buttonWasPressedForSendConfig:(id)sender {
    [_appDelegate.floReaderManager setStandaloneMode:_switchPolling14443A.isOn];
    [_appDelegate.floReaderManager setStandaloneMode:_switchPolling15693.isOn];
    [_appDelegate.floReaderManager setStandaloneMode:_switchPollingFelica.isOn];
    [_appDelegate.floReaderManager setStandaloneMode:_switchStandaloneMode.isOn];
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

- (void)updateLogTextViewWithString:(NSString *)updateString {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.outputTextView.text = [NSString stringWithFormat:@"%@ \n%@", updateString, self.outputTextView.text];
    });
}

- (void) handleDeviceStateNotification:(NSNotification*)note
{
    NSData * info = [[note userInfo]objectForKey:@"state"];
    //    NSInteger state;[info getBytes:&state length:1];
    NSUInteger * infoBytes = (NSUInteger*)info.bytes;
    deviceState_t state = (deviceState_t)infoBytes[0];
    
    NSString * stateText;
    NSString * name;
    BOOL gref = NO;
    switch (state)
    {
        case Off:
            stateText = @"Off";
            [_appDelegate.oadFile setConnectedState:NO];
            break;
        case On:
            stateText = @"On";
            [_appDelegate.oadFile setConnectedState:NO];
            break;
        case Disconnected:
            stateText = @"Disconnected";
            [_appDelegate.oadFile setConnectedState:NO];
            break;
        case Scanning:
            stateText = @"Scanning";
            [_appDelegate.oadFile setConnectedState:NO];
            break;
        case PeripheralDetected:
            stateText = @"Peripheral Detected";
            [_appDelegate.oadFile setConnectedState:NO];
            break;
        case Connected:
//            stateText = @"Connected";
            [_appDelegate.oadFile setConnectedState:NO];
            name = [[_appDelegate.floReaderManager nfcService].activePeripheral name];
            stateText = [NSString stringWithFormat:@"Connected %@ ",name];
            break;
        case Services:
//            stateText = @"Connected w/ Services";
            [_appDelegate.oadFile setConnectedState:YES];
            name = [[_appDelegate.floReaderManager nfcService].activePeripheral name];
            stateText = [NSString stringWithFormat:@"Connected w/ Services %@ ",name];
            break;
        case Badanamu:
//            stateText = @"Connected w/ Badanamu";
            [_appDelegate.oadFile setConnectedState:YES];
            name = [[_appDelegate.floReaderManager nfcService].activePeripheral name];
            stateText = [NSString stringWithFormat:@"Connected w/ Services %@ ",name];
            gref = YES;
            break;
        default:
            stateText = @"Unknown";
            break;
    }
    
    [self connectionStatusTextField].text = [NSString stringWithFormat:@"%@",stateText];
    NSLog(@"handleDeviceStateNotification - DeviceState %@",stateText);
    if (gref)
    {
        gref = NO;
        NSLog(@"uidButton");
        [_appDelegate.floReaderManager setModeReadTagUID];
    }
}

- (void)updateStatusTextViewWithStatus:(NSInteger)statusCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (statusCode) {
            case FLOMIO_STATUS_PING_RECIEVED:
                _statusPingPongCount++;
                _statusPingPongTextView.text = [NSString stringWithFormat:@"Msgs: %d",_statusPingPongCount];
                break;
            case FLOMIO_STATUS_NACK_ERROR:
                _statusNACKCount++;
                _statusNACKTextView.text = [NSString stringWithFormat:@"Issues: %d",_statusNACKCount];
                break;
            case FLOMIO_STATUS_VOLUME_LOW_ERROR:
                _statusVolumeLowErrorTextView.text = [NSString stringWithFormat:@"**ERROR** Vol low"];
                break;
            case FLOMIO_STATUS_VOLUME_OK:
                _statusVolumeLowErrorTextView.text = [NSString stringWithFormat:@"Vol OK"];
            case FLOMIO_STATUS_MESSAGE_CORRUPT_ERROR:
                // fall through
            case FLOMIO_STATUS_GENERIC_ERROR:
                _statusErrorCount++;
                _statusErrorTextView.text = [NSString stringWithFormat:@"ERR: %d", _statusErrorCount];
                break;
            default:
                break;
        }
    });
}

#pragma mark - FLOReaderManager Delegate

- (void)floReaderManager:(FLOReaderManager *)floReaderManager didScanTag:(FJNFCTag *)theNfcTag {
    NSMutableString *textUpdate = [NSMutableString stringWithFormat:@":::Tag Read "];
    [textUpdate appendString:[NSString stringWithFormat:@"\n UID: %@", [theNfcTag.uid fj_asHexString]]];
//    [textUpdate appendString:[NSString stringWithFormat:@"\n Type: %d", theNfcTag.nfcForumType]];
    [textUpdate appendString:[NSString stringWithFormat:@"\n Type: %@", [tagTypeStrings objectAtIndex:theNfcTag.nfcForumType]]];
    [textUpdate appendString:[NSString stringWithFormat:@"\n Data: %@", [theNfcTag.data fj_asHexString]]];

    if (theNfcTag.ndefMessage != nil && theNfcTag.ndefMessage.ndefRecords != nil) {
        for (NDEFRecord *ndefRecord in theNfcTag.ndefMessage.ndefRecords) {
            [textUpdate appendString:@"\n:::NDEF Record Found"];
            [textUpdate appendString:[NSString stringWithFormat:@"\n TNF: %d",ndefRecord.tnf]];
            [textUpdate appendString:[NSString stringWithFormat:@"\n Type: %@",[ndefRecord.type fj_asHexString]]];
            [textUpdate appendString:[NSString stringWithFormat:@"\n Payload: %@ (%@)",[ndefRecord.payload fj_asHexString], [ndefRecord.payload fj_asASCIIStringEncoded]]];
            
            NSURL *url = [ndefRecord getUriFromPayload];
            if (url != nil) {
                [textUpdate appendString:[NSString stringWithFormat:@"\nURI: %@", url.description]];
            }
        }
    }
    [self updateLogTextViewWithString:textUpdate];
}

- (void)floReaderManager:(FLOReaderManager *)floReaderManager didHaveStatus:(NSInteger)statusCode {
    NSString *statusCodeString = [FJMessage formatStatusCodesToString:(flomio_nfc_adapter_status_codes_t)statusCode];
    NSLog(statusCodeString);
    NSString *textUpdate = [NSString stringWithFormat:@":::FloBLE Status %@", statusCodeString];
    [self updateLogTextViewWithString:textUpdate];
    [self updateStatusTextViewWithStatus:statusCode];
}

- (void)floReaderManager:(FLOReaderManager *)floReaderManager didWriteTagAndStatusWas:(NSInteger)statusCode {
    NSString *statusCodeString = [FJMessage formatTagWriteStatusToString:(flomio_tag_write_status_opcodes_t)statusCode];
    NSString *textUpdate = [NSString stringWithFormat:@":::Tag Write Status %@", statusCodeString];
    [self updateLogTextViewWithString:textUpdate];
    [self showAlertWithTitle:@"Tag Write Status" andMessage:statusCodeString];
}

- (void)floReaderManager:(FLOReaderManager *)floReaderManager didReceiveFirmwareVersion:(NSString *)theVersionNumber {
    NSString *textUpdate = [NSString stringWithFormat:@":::FloBLE Firmware Version %@", theVersionNumber];
    [self updateLogTextViewWithString:textUpdate];
}

- (void)floReaderManager:(FLOReaderManager *)floReaderManager didReceiveHardwareVersion:(NSString *)theVersionNumber; {
    NSString *textUpdate = [NSString stringWithFormat:@":::FloBLE Hardware Version %@", theVersionNumber];
    [self updateLogTextViewWithString:textUpdate];
}

- (void)floReaderManager:(FLOReaderManager *)floReaderManager didReceiveSnifferThresh:(NSString *)theSnifferValue; {
    NSString *textUpdate = [NSString stringWithFormat:@":::FloBLE Sniffer Threshold %@", theSnifferValue];
    [self updateLogTextViewWithString:textUpdate];
}

- (void)floReaderManager:(FLOReaderManager *)floReaderManager didReceiveSnifferCalib:(NSString *)theCalibValues; {
    NSString *textUpdate = [NSString stringWithFormat:@":::FloBLE Sniffer Calibration Stats %@", theCalibValues];
    [self updateLogTextViewWithString:textUpdate];
}

- (bool)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_urlInputField]) {
        [_appDelegate.floReaderManager setModeWriteTagWithNdefMessage:[NDEFMessage createURIWithString:_urlInputField.text]];
    } else if ([textField isEqual:_pollingRateTextField]) {
            _appDelegate.floReaderManager.pollPeriod = [self.pollingRateTextField.text intValue];
    } else if ([textField isEqual:_tweakThresholdTextField]) {
        [_appDelegate.floReaderManager setIncrementSnifferThreshold:[self.tweakThresholdTextField.text intValue]];
    } else if ([textField isEqual:_maxThresholdTextField]) {
        [_appDelegate.floReaderManager setMaxSnifferThreshold:[self.maxThresholdTextField.text intValue]];
    }
    [self.view endEditing:YES];
    return YES;
}

- (void)viewDidUnload {
    [self setTweakThresholdTextField:nil];
    [self setMaxThresholdTextField:nil];
    [self setSwitchPolling14443A:nil];
    [self setSwitchPolling15693:nil];
    [self setSwitchPollingFelica:nil];
    [self setSwitchStandaloneMode:nil];
    [super viewDidUnload];
}
@end
