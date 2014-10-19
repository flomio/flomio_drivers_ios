//
//  MainViewController.m
//  EMVCardReader
//
//  Created by Boris  on 10/17/14.
//  Copyright (c) 2014 LLT. All rights reserved.
//
#import "MainViewController.h"
#import <CommonCrypto/CommonCrypto.h>
#import "AJDHex.h"  // TODO: this file shouldn't be needed as functions are duplicated here.

@implementation MainViewController {
    
    ACRAudioJackReader *_reader;
    ACRDukptReceiver *_dukptReceiver;
    int _swipeCount;
    
    NSCondition *_responseCondition;
    
    BOOL _firmwareVersionReady;
    NSString *_firmwareVersion;
    
    BOOL _statusReady;
    ACRStatus *_status;
    
    BOOL _resultReady;
    ACRResult *_result;
    
    BOOL _customIdReady;
    NSData *_customId;
    
    BOOL _deviceIdReady;
    NSData *_deviceId;
    
    BOOL _dukptOptionReady;
    BOOL _dukptOption;
    
    BOOL _trackDataOptionReady;
    ACRTrackDataOption _trackDataOption;
    
    BOOL _piccAtrReady;
    NSData *_piccAtr;
    
    BOOL _piccResponseApduReady;
    NSData *_piccResponseApdu;
    
    NSUserDefaults *_defaults;
    NSData *_masterKey;
    NSData *_masterKey2;
    NSData *_aesKey;
    NSData *_iksn;
    NSData *_ipek;
    
    NSString *_piccTimeoutString;
    NSString *_piccCardTypeString;
    NSString *_piccCommandApduString;
    NSString *_piccRfConfigString;
    
    NSUInteger _piccTimeout;
    NSUInteger _piccCardType;
    NSData *_piccCommandApdu;
    NSData *_piccRfConfig;
    
    UIAlertView *_trackDataAlert;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initialize ACRAudioJackReader object.
    _reader = [[ACRAudioJackReader alloc] init];
    [_reader setDelegate:self];
    
    _swipeCount = 0;
    
    _responseCondition = [[NSCondition alloc] init];
    
    _firmwareVersionReady = NO;
    _firmwareVersion = nil;
    
    _statusReady = NO;
    _status = nil;
    
    _resultReady = NO;
    _result = nil;
    
    _customIdReady = NO;
    _customId = nil;
    
    _deviceIdReady = NO;
    _deviceId = nil;
    
    _dukptOptionReady = NO;
    _dukptOption = NO;
    
    _trackDataOptionReady = NO;
    _trackDataOption = NO;
    
    _piccAtrReady = NO;
    _piccAtr = nil;
    
    _piccResponseApduReady = NO;
    _piccResponseApdu = nil;
    
    // Load the settings.
    _defaults = [NSUserDefaults standardUserDefaults];
    
    _masterKey = [_defaults dataForKey:@"MasterKey"];
    if (_masterKey == nil) {
        _masterKey = [AJDHex byteArrayFromHexString:@"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"]; // TODO: Need to swap AJDHex class for local function call as Utilities are continaed herein
    }
    
    _masterKey2 = [_defaults dataForKey:@"MasterKey2"];
    if (_masterKey2 == nil) {
        _masterKey2 = [AJDHex byteArrayFromHexString:@"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"];
    }
    
    _aesKey = [_defaults dataForKey:@"AesKey"];
    if (_aesKey == nil) {
        _aesKey = [AJDHex byteArrayFromHexString:@"4E 61 74 68 61 6E 2E 4C 69 20 54 65 64 64 79 20"];
    }
    
    _iksn = [_defaults dataForKey:@"IKSN"];
    if (_iksn == nil) {
        _iksn = [AJDHex byteArrayFromHexString:@"FF FF 98 76 54 32 10 E0 00 00"];
    }
    
    _ipek = [_defaults dataForKey:@"IPEK"];
    if (_ipek == nil) {
        _ipek = [AJDHex byteArrayFromHexString:@"6A C2 92 FA A1 31 5B 4D 85 8A B3 A3 D7 D5 93 3A"];
    }
    
    _piccTimeoutString = [_defaults stringForKey:@"PiccTimeout"];
    _piccCardTypeString = [_defaults stringForKey:@"PiccCardType"];
    _piccCommandApduString = [_defaults stringForKey:@"PiccCommandApdu"];
    _piccRfConfigString = [_defaults stringForKey:@"PiccRfConfig"];
    
    if (_piccTimeoutString == nil) {
        _piccTimeoutString = @"1";
    }
    
    if (_piccCardTypeString == nil) {
        _piccCardTypeString = @"8F";
    }
    
    if (_piccCommandApduString == nil) {
        _piccCommandApduString = @"00 84 00 00 08";
    }
    
    if (_piccRfConfigString == nil) {
        _piccRfConfigString = @"07 85 85 85 85 85 85 85 85 69 69 69 69 69 69 69 69 3F 3F";
    }
    
    _piccTimeout = [_piccTimeoutString integerValue];
    uint8_t cardType[] = { 0 };
    [self toByteArray:_piccCardTypeString buffer:cardType bufferSize:sizeof(cardType)];
    _piccCardType = cardType[0];
    _piccCommandApdu = [self toByteArray:_piccCommandApduString];
    _piccRfConfig = [self toByteArray:_piccRfConfigString];
    
//    self.swipeCountLabel.text = @"0";
//    self.batteryStatusLabel.text = @"";
//    self.dataReceivedLabel.font = [UIFont fontWithName:@"Courier" size:14.0];
//    self.dataReceivedLabel.numberOfLines = 0;
//    self.dataReceivedLabel.text = @"";
//    self.keySerialNumberLabel.text = @"";
//    self.track1MacLabel.text = @"";
//    self.track2MacLabel.text = @"";
//    
//    self.track1Jis2DataLabel.numberOfLines = 0;
//    self.track1Jis2DataLabel.text = @"";
//    self.track1PrimaryAccountNumberLabel.numberOfLines = 0;
//    self.track1PrimaryAccountNumberLabel.text = @"";
//    self.track1NameLabel.numberOfLines = 0;
//    self.track1NameLabel.text = @"";
//    self.track1ExpirationDateLabel.numberOfLines = 0;
//    self.track1ExpirationDateLabel.text = @"";
//    self.track1ServiceCodeLabel.numberOfLines = 0;
//    self.track1ServiceCodeLabel.text = @"";
//    self.track1DiscretionaryDataLabel.numberOfLines = 0;
//    self.track1DiscretionaryDataLabel.text = @"";
//    
//    self.track2PrimaryAccountNumberLabel.numberOfLines = 0;
//    self.track2PrimaryAccountNumberLabel.text = @"";
//    self.track2ExpirationDateLabel.numberOfLines = 0;
//    self.track2ExpirationDateLabel.text = @"";
//    self.track2ServiceCodeLabel.numberOfLines = 0;
//    self.track2ServiceCodeLabel.text = @"";
//    self.track2DiscretionaryDataLabel.numberOfLines = 0;
//    self.track2DiscretionaryDataLabel.text = @"";
    
    // Initialize the DUKPT receiver object.
    _dukptReceiver = [[ACRDukptReceiver alloc] init];
    
    // Set the key serial number.
    [_dukptReceiver setKeySerialNumber:_iksn];
    
    // Load the initial key.
    [_dukptReceiver loadInitialKey:_ipek];
    
    // Do any additional setup after loading the view
    [self createLeftMenu];

}

- (void)createLeftMenu {
    
    leftMenu = [[LeftMenuView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    leftMenu.backgroundColor = [UIColor grayColor];
    leftMenu.alpha = 0.7;
    leftMenu.navigationController = self.navigationController;
    [self.view addSubview:leftMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Next:(id)sender {
    
    UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tab"];
    [self.navigationController pushViewController:tbc animated:YES];
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    startPosition = [touch locationInView:self.view];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint endPosition = [touch locationInView:self.view];
    
    if (startPosition.x < endPosition.x) {
        // Right swipe
        [leftMenu open];
        
    } else {
        // Left swipe
        [leftMenu close];
        
    }
    
    
}

#pragma mark - Utility functions

- (NSString *)toHexString:(const uint8_t *)buffer length:(size_t)length {
    
    NSString *hexString = @"";
    size_t i = 0;
    
    for (i = 0; i < length; i++) {
        if (i == 0) {
            hexString = [hexString stringByAppendingFormat:@"%02X", buffer[i]];
        } else {
            hexString = [hexString stringByAppendingFormat:@" %02X", buffer[i]];
        }
    }
    
    return hexString;
}

- (NSUInteger)toByteArray:(NSString *)hexString buffer:(uint8_t *)buffer bufferSize:(NSUInteger)bufferSize {
    
    NSUInteger length = 0;
    BOOL first = YES;
    int num = 0;
    unichar c = 0;
    NSUInteger i = 0;
    
    for (i = 0; i < [hexString length]; i++) {
        
        c = [hexString characterAtIndex:i];
        if ((c >= '0') && (c <= '9')) {
            num = c - '0';
        } else if ((c >= 'A') && (c <= 'F')) {
            num = c - 'A' + 10;
        } else if ((c >= 'a') && (c <= 'f')) {
            num = c - 'a' + 10;
        } else {
            num = -1;
        }
        
        if (num >= 0) {
            
            if (first) {
                
                buffer[length] = num << 4;
                
            } else {
                
                buffer[length] |= num;
                length++;
            }
            
            first = !first;
        }
        
        if (length >= bufferSize) {
            break;
        }
    }
    
    return length;
}

- (NSData *)toByteArray:(NSString *)hexString {
    
    NSData *byteArray = nil;
    uint8_t *buffer = NULL;
    NSUInteger i = 0;
    unichar c = 0;
    NSUInteger count = 0;
    int num = 0;
    BOOL first = YES;
    NSUInteger length = 0;
    
    // Count the number of HEX characters.
    for (i = 0; i < [hexString length]; i++) {
        
        c = [hexString characterAtIndex:i];
        if (((c >= '0') && (c <= '9')) ||
            ((c >= 'A') && (c <= 'F')) ||
            ((c >= 'a') && (c <= 'f'))) {
            count++;
        }
    }
    
    // Allocate the buffer.
    buffer = (uint8_t *) malloc((count + 1) / 2);
    
    if (buffer != NULL) {
        
        for (i = 0; i < [hexString length]; i++) {
            
            c = [hexString characterAtIndex:i];
            if ((c >= '0') && (c <= '9')) {
                num = c - '0';
            } else if ((c >= 'A') && (c <= 'F')) {
                num = c - 'A' + 10;
            } else if ((c >= 'a') && (c <= 'f')) {
                num = c - 'a' + 10;
            } else {
                num = -1;
            }
            
            if (num >= 0) {
                
                if (first) {
                    
                    buffer[length] = num << 4;
                    
                } else {
                    
                    buffer[length] |= num;
                    length++;
                }
                
                first = !first;
            }
        }
        
        // Create the byte array.
        byteArray = [[NSData alloc] initWithBytes:buffer length:length];
        
        // Free the buffer.
        free(buffer);
        buffer = NULL;
    }
    
    return byteArray;
}

- (NSString *)toBatteryLevelString:(NSUInteger)batteryLevel {
    
    NSString *batteryLevelString = nil;
    
    switch (batteryLevel) {
        case 0:
            batteryLevelString = @">= 3.00V";
            break;
        case 1:
            batteryLevelString = @"2.90V - 2.99V";
            break;
        case 2:
            batteryLevelString = @"2.80V - 2.89V";
            break;
        case 3:
            batteryLevelString = @"2.70V - 2.79V";
            break;
        case 4:
            batteryLevelString = @"2.60V - 2.69V";
            break;
        case 5:
            batteryLevelString = @"2.50V - 2.59V";
            break;
        case 6:
            batteryLevelString = @"2.40V - 2.49V";
            break;
        case 7:
            batteryLevelString = @"2.30V - 2.39V";
            break;
        case 8:
            batteryLevelString = @"< 2.30V";
            break;
        default:
            batteryLevelString = @"Unknown";
            break;
    }
    
    return batteryLevelString;
}

- (NSString *)toErrorCodeString:(NSUInteger)errorCode {
    
    NSString *errorCodeString = nil;
    
    switch (errorCode) {
        case ACRErrorSuccess:
            errorCodeString = @"The operation completed successfully.";
            break;
        case ACRErrorInvalidCommand:
            errorCodeString = @"The command is invalid.";
            break;
        case ACRErrorInvalidParameter:
            errorCodeString = @"The parameter is invalid.";
            break;
        case ACRErrorInvalidChecksum:
            errorCodeString = @"The checksum is invalid.";
            break;
        case ACRErrorInvalidStartByte:
            errorCodeString = @"The start byte is invalid.";
            break;
        case ACRErrorUnknown:
            errorCodeString = @"The error is unknown.";
            break;
        case ACRErrorDukptOperationCeased:
            errorCodeString = @"The DUKPT operation is ceased.";
            break;
        case ACRErrorDukptDataCorrupted:
            errorCodeString = @"The DUKPT data is corrupted.";
            break;
        case ACRErrorFlashDataCorrupted:
            errorCodeString = @"The flash data is corrupted.";
            break;
        case ACRErrorVerificationFailed:
            errorCodeString = @"The verification is failed.";
            break;
        default:
            errorCodeString = @"Error communicating with reader.";
            break;
    }
    
    return errorCodeString;
}

- (BOOL)decryptData:(const void *)dataIn dataInLength:(size_t)dataInLength key:(const void *)key keyLength:(size_t)keyLength dataOut:(void *)dataOut dataOutLength:(size_t)dataOutLength pBytesReturned:(size_t *)pBytesReturned {
    
    BOOL ret = NO;
    
    // Decrypt the data.
    if (CCCrypt(kCCDecrypt, kCCAlgorithmAES128, 0, key, keyLength, NULL, dataIn, dataInLength, dataOut, dataOutLength, pBytesReturned) == kCCSuccess) {
        ret = YES;
    }
    
    return ret;
}

// TODO: This is the function that should clear all the fields in the app or Credit Card data
- (IBAction)clearData:(id)sender {
    
    _swipeCount = 0;
    
//    self.swipeCountLabel.text = @"0";
//    self.batteryStatusLabel.text = @"";
//    self.dataReceivedLabel.text = @"";
//    self.keySerialNumberLabel.text = @"";
//    self.track1MacLabel.text = @"";
//    self.track2MacLabel.text = @"";
//    
//    self.track1Jis2DataLabel.text = @"";
//    self.track1PrimaryAccountNumberLabel.text = @"";
//    self.track1NameLabel.text = @"";
//    self.track1ExpirationDateLabel.text = @"";
//    self.track1ServiceCodeLabel.text = @"";
//    self.track1DiscretionaryDataLabel.text = @"";
//    
//    self.track2PrimaryAccountNumberLabel.text = @"";
//    self.track2ExpirationDateLabel.text = @"";
//    self.track2ServiceCodeLabel.text = @"";
//    self.track2DiscretionaryDataLabel.text = @"";
//    
//    [self.tableView reloadData];
}

- (void)resetReader {
    
    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Resetting the reader..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    
    // Reset the reader.
    [_reader resetWithCompletion:^{
        
        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }];
}

- (void)setSleep {
    
    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Setting the reader to sleep..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Set the reader to sleep.
        _resultReady = NO;
        if (![_reader sleep]) {
            
            // TODO: Show the sleep request queue error (this should only happen when App goes to background so perhaps a Nitification?).
            
        } else {
            
            // This is simply a place holder for the Successful Sleep state. Not needed for this app.
        }
        
        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    });
}

#pragma mark - Audio Jack Reader

- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result {
    
    [_responseCondition lock];
    _result = result;
    _resultReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendFirmwareVersion:(NSString *)firmwareVersion {
    
    [_responseCondition lock];
    _firmwareVersion = firmwareVersion;
    _firmwareVersionReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendStatus:(ACRStatus *)status {
    
    [_responseCondition lock];
    _status = status;
    _statusReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)readerDidNotifyTrackData:(ACRAudioJackReader *)reader {
    
    // Show the track data alert.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _trackDataAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Processing the track data..." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [_trackDataAlert show];
        
        // Dismiss the track data alert after 5 seconds.
        [self performSelector:@selector(AJD_dismissAlertView:) withObject:_trackDataAlert afterDelay:5];
    });
}

- (void)reader:(ACRAudioJackReader *)reader didSendTrackData:(ACRTrackData *)trackData {
    
    ACRTrack1Data *track1Data = [[ACRTrack1Data alloc] init];
    ACRTrack2Data *track2Data = [[ACRTrack2Data alloc] init];
    ACRTrack1Data *track1MaskedData = [[ACRTrack1Data alloc] init];
    ACRTrack2Data *track2MaskedData = [[ACRTrack2Data alloc] init];
    NSString *track1MacString = @"";
    NSString *track2MacString = @"";
    NSString *batteryStatusString = [self AJD_stringFromBatteryStatus:trackData.batteryStatus];
    NSString *keySerialNumberString = @"";
    NSString *errorString = @"";
    
    // Dismiss the track data alert.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self AJD_dismissAlertView:_trackDataAlert];
    });
    
    if ((trackData.track1ErrorCode != ACRTrackErrorSuccess) &&
        (trackData.track2ErrorCode != ACRTrackErrorSuccess)) {
        
        errorString = @"The track 1 and track 2 data";
        
    } else {
        
        if (trackData.track1ErrorCode != ACRTrackErrorSuccess) {
            errorString = @"The track 1 data";
        }
        
        if (trackData.track2ErrorCode != ACRTrackErrorSuccess) {
            errorString = @"The track 2 data";
        }
    }
    
    errorString = [errorString stringByAppendingString:@" may be corrupted. Please swipe the card again!"];
    
    // Show the track error.
    if ((trackData.track1ErrorCode != ACRTrackErrorSuccess) ||
        (trackData.track2ErrorCode != ACRTrackErrorSuccess)) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorString message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        });
    }
    
    if ([trackData isKindOfClass:[ACRAesTrackData class]]) {
        
        ACRAesTrackData *aesTrackData = (ACRAesTrackData *) trackData;
        uint8_t *buffer = (uint8_t *) [aesTrackData.trackData bytes];
        NSUInteger bufferLength = [aesTrackData.trackData length];
        uint8_t decryptedTrackData[128];
        size_t decryptedTrackDataLength = 0;
        
        // Decrypt the track data.
        if (![self decryptData:buffer dataInLength:bufferLength key:[_aesKey bytes] keyLength:[_aesKey length] dataOut:decryptedTrackData dataOutLength:sizeof(decryptedTrackData) pBytesReturned:&decryptedTrackDataLength]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The track data cannot be decrypted. Please swipe the card again!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
            
            goto cleanup;
        }
        
        // Verify the track data.
        if (![_reader verifyData:decryptedTrackData length:decryptedTrackDataLength]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The track data contains checksum error. Please swipe the card again!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
            
            goto cleanup;
        }
        
        // Decode the track data.
        track1Data = [track1Data initWithBytes:decryptedTrackData length:trackData.track1Length];
        track2Data = [track2Data initWithBytes:decryptedTrackData + 79 length:trackData.track2Length];
        
    } else if ([trackData isKindOfClass:[ACRDukptTrackData class]]) {
        
        ACRDukptTrackData *dukptTrackData = (ACRDukptTrackData *) trackData;
        NSUInteger ec = 0;
        NSUInteger ec2 = 0;
        NSData *key = nil;
        NSData *dek = nil;
        NSData *macKey = nil;
        uint8_t dek3des[24];
        
        keySerialNumberString = [AJDHex hexStringFromByteArray:dukptTrackData.keySerialNumber];
        track1MacString = [AJDHex hexStringFromByteArray:dukptTrackData.track1Mac];
        track2MacString = [AJDHex hexStringFromByteArray:dukptTrackData.track2Mac];
        track1MaskedData = [track1MaskedData initWithString:dukptTrackData.track1MaskedData];
        track2MaskedData = [track2MaskedData initWithString:dukptTrackData.track2MaskedData];
        
        // Compare the key serial number.
        if (![ACRDukptReceiver compareKeySerialNumber:_iksn ksn2:dukptTrackData.keySerialNumber]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The key serial number does not match with the settings." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
            
            goto cleanup;
        }
        
        // Get the encryption counter from KSN.
        ec = [ACRDukptReceiver encryptionCounterFromKeySerialNumber:dukptTrackData.keySerialNumber];
        
        // Get the encryption counter from DUKPT receiver.
        ec2 = [_dukptReceiver encryptionCounter];
        
        // Load the initial key if the encryption counter from KSN is less than
        // the encryption counter from DUKPT receiver.
        if (ec < ec2) {
            
            [_dukptReceiver loadInitialKey:_ipek];
            ec2 = [_dukptReceiver encryptionCounter];
        }
        
        // Synchronize the key if the encryption counter from KSN is greater
        // than the encryption counter from DUKPT receiver.
        while (ec > ec2) {
            
            [_dukptReceiver key];
            ec2 = [_dukptReceiver encryptionCounter];
        }
        
        if (ec != ec2) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The encryption counter is invalid." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
            
            goto cleanup;
        }
        
        key = [_dukptReceiver key];
        if (key == nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The maximum encryption count had been reached." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
            
            goto cleanup;
        }
        
        dek = [ACRDukptReceiver dataEncryptionRequestKeyFromKey:key];
        macKey = [ACRDukptReceiver macRequestKeyFromKey:key];
        
        // Generate 3DES key (K1 = K3).
        memcpy(dek3des, [dek bytes], [dek length]);
        memcpy(dek3des + [dek length], [dek bytes], 8);
        
        if (dukptTrackData.track1Data != nil) {
            
            uint8_t track1Buffer[80];
            size_t bytesReturned = 0;
            NSString *track1DataString = nil;
            
            // Decrypt the track 1 data.
            if (![self AJD_tripleDesDecryptData:[dukptTrackData.track1Data bytes] dataInLength:[dukptTrackData.track1Data length] key:dek3des keyLength:sizeof(dek3des) dataOut:track1Buffer dataOutLength:sizeof(track1Buffer) bytesReturned:&bytesReturned]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The track 1 data cannot be decrypted. Please swipe the card again!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                });
                
                goto cleanup;
            }
            
            // Generate the MAC for track 1 data.
            track1MacString = [track1MacString stringByAppendingFormat:@" (%@)", [AJDHex hexStringFromByteArray:[ACRDukptReceiver macFromData:track1Buffer dataLength:sizeof(track1Buffer) key:[macKey bytes] keyLength:[macKey length]]]];
            
            // Get the track 1 data as string.
            track1DataString = [[NSString alloc] initWithBytes:track1Buffer length:dukptTrackData.track1Length encoding:NSASCIIStringEncoding];
            
            // Divide the track 1 data into fields.
            track1Data = [track1Data initWithString:track1DataString];
        }
        
        if (dukptTrackData.track2Data != nil) {
            
            uint8_t track2Buffer[48];
            size_t bytesReturned = 0;
            NSString *track2DataString = nil;
            
            // Decrypt the track 2 data.
            if (![self AJD_tripleDesDecryptData:[dukptTrackData.track2Data bytes] dataInLength:[dukptTrackData.track2Data length] key:dek3des keyLength:sizeof(dek3des) dataOut:track2Buffer dataOutLength:sizeof(track2Buffer) bytesReturned:&bytesReturned]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The track 2 data cannot be decrypted. Please swipe the card again!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                });
                
                goto cleanup;
            }
            
            // Generate the MAC for track 2 data.
            track2MacString = [track2MacString stringByAppendingFormat:@" (%@)", [AJDHex hexStringFromByteArray:[ACRDukptReceiver macFromData:track2Buffer dataLength:sizeof(track2Buffer) key:[macKey bytes] keyLength:[macKey length]]]];
            
            // Get the track 2 data as string.
            track2DataString = [[NSString alloc] initWithBytes:track2Buffer length:dukptTrackData.track2Length encoding:NSASCIIStringEncoding];
            
            // Divide the track 2 data into fields.
            track2Data = [track2Data initWithString:track2DataString];
        }
    }
    
cleanup:
    
    // Show the data.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _swipeCount++;
//        self.swipeCountLabel.text = [NSString stringWithFormat:@"%d", _swipeCount];
//        
//        self.batteryStatusLabel.text = batteryStatusString;
//        self.keySerialNumberLabel.text = keySerialNumberString;
//        self.track1MacLabel.text = track1MacString;
//        self.track2MacLabel.text = track2MacString;
//        
//        self.track1Jis2DataLabel.text = track1Data.jis2Data;
//        self.track1PrimaryAccountNumberLabel.text = [NSString stringWithFormat:@"%@\n%@", track1Data.primaryAccountNumber, track1MaskedData.primaryAccountNumber];
//        self.track1NameLabel.text = [NSString stringWithFormat:@"%@\n%@", track1Data.name, track1MaskedData.name];
//        self.track1ExpirationDateLabel.text = [NSString stringWithFormat:@"%@\n%@", track1Data.expirationDate, track1MaskedData.expirationDate];
//        self.track1ServiceCodeLabel.text = [NSString stringWithFormat:@"%@\n%@", track1Data.serviceCode, track1MaskedData.serviceCode];
//        self.track1DiscretionaryDataLabel.text = [NSString stringWithFormat:@"%@\n%@", track1Data.discretionaryData, track1MaskedData.discretionaryData];
//        
//        self.track2PrimaryAccountNumberLabel.text = [NSString stringWithFormat:@"%@\n%@", track2Data.primaryAccountNumber, track2MaskedData.primaryAccountNumber];
//        self.track2ExpirationDateLabel.text = [NSString stringWithFormat:@"%@\n%@", track2Data.expirationDate, track2MaskedData.expirationDate];
//        self.track2ServiceCodeLabel.text = [NSString stringWithFormat:@"%@\n%@", track2Data.serviceCode, track2MaskedData.serviceCode];
//        self.track2DiscretionaryDataLabel.text = [NSString stringWithFormat:@"%@\n%@", track2Data.discretionaryData, track2MaskedData.discretionaryData];
//        
//        [self.tableView reloadData];
    });
}

- (void)reader:(ACRAudioJackReader *)reader didSendRawData:(const uint8_t *)rawData length:(NSUInteger)length {
    
    NSString *hexString = [self toHexString:rawData length:length];
    
    hexString = [hexString stringByAppendingString:[_reader verifyData:rawData length:length] ? @" (Checksum OK)" : @" (Checksum Error)"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // TODO: This is where I need to display the hexString into the Card Details/Log Console views.
          // self.dataReceivedLabel.text = hexString;
          // [self.tableView reloadData];
    });
}

- (void)reader:(ACRAudioJackReader *)reader didSendCustomId:(const uint8_t *)customId length:(NSUInteger)length {
    
    [_responseCondition lock];
    _customId = [NSData dataWithBytes:customId length:length];
    _customIdReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendDeviceId:(const uint8_t *)deviceId length:(NSUInteger)length {
    
    [_responseCondition lock];
    _deviceId = [NSData dataWithBytes:deviceId length:length];
    _deviceIdReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendDukptOption:(BOOL)enabled {
    
    [_responseCondition lock];
    _dukptOption = enabled;
    _dukptOptionReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendTrackDataOption:(ACRTrackDataOption)option {
    
    [_responseCondition lock];
    _trackDataOption = option;
    _trackDataOptionReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendPiccAtr:(const uint8_t *)atr length:(NSUInteger)length {
    
    [_responseCondition lock];
    _piccAtr = [NSData dataWithBytes:atr length:length];
    _piccAtrReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendPiccResponseApdu:(const uint8_t *)responseApdu length:(NSUInteger)length {
    
    [_responseCondition lock];
    _piccResponseApdu = [NSData dataWithBytes:responseApdu length:length];
    _piccResponseApduReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

#pragma mark - Private Methods

/**
 * Converts the battery status to string.
 * @param batteryStatus the battery status.
 * @return the battery status string.
 */
- (NSString *)AJD_stringFromBatteryStatus:(NSUInteger)batteryStatus {
    
    NSString *batteryStatusString = nil;
    
    switch (batteryStatus) {
            
        case ACRBatteryStatusLow:
            batteryStatusString = @"Low";
            break;
            
        case ACRBatteryStatusFull:
            batteryStatusString = @"Full";
            break;
            
        default:
            batteryStatusString = @"Unknown";
            break;
    }
    
    return batteryStatusString;
}

/**
 * Decrypts the data using Triple DES.
 * @param dataIn           the input buffer.
 * @param dataInLength     the input buffer length.
 * @param key              the key.
 * @param keyLength        the key length.
 * @param dataOut          the output buffer.
 * @param dataOutLength    the output buffer length.
 * @param bytesReturnedPtr the pointer to number of bytes returned.
 * @return <code>YES</code> if the operation completed successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)AJD_tripleDesDecryptData:(const void *)dataIn dataInLength:(size_t)dataInLength key:(const void *)key keyLength:(size_t)keyLength dataOut:(void *)dataOut dataOutLength:(size_t)dataOutLength bytesReturned:(size_t *)bytesReturnedPtr {
    
    BOOL ret = NO;
    
    // Decrypt the data.
    if (CCCrypt(kCCDecrypt, kCCAlgorithm3DES, 0, key, keyLength, NULL, dataIn, dataInLength, dataOut, dataOutLength, bytesReturnedPtr) == kCCSuccess) {
        ret = YES;
    }
    
    return ret;
}

/**
 * Dismisses the alert view.
 * @param alertView the alert view.
 */
- (void)AJD_dismissAlertView:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}


@end
