/*
 * Copyright (C) 2013 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "AJDMasterViewController.h"
#import <CommonCrypto/CommonCrypto.h>
#import "AJDHex.h"

@interface AJDMasterViewController ()

@property (weak, nonatomic) IBOutlet UILabel *swipeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataReceivedLabel;
@property (weak, nonatomic) IBOutlet UILabel *keySerialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *track1MacLabel;
@property (weak, nonatomic) IBOutlet UILabel *track2MacLabel;

@property (weak, nonatomic) IBOutlet UILabel *track1Jis2DataLabel;
@property (weak, nonatomic) IBOutlet UILabel *track1PrimaryAccountNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *track1NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *track1ExpirationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *track1ServiceCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *track1DiscretionaryDataLabel;

@property (weak, nonatomic) IBOutlet UILabel *track2PrimaryAccountNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *track2ExpirationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *track2ServiceCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *track2DiscretionaryDataLabel;

- (IBAction)clearData:(id)sender;

@end

@implementation AJDMasterViewController {

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
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
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
        _masterKey = [AJDHex byteArrayFromHexString:@"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"];
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

    self.swipeCountLabel.text = @"0";
    self.batteryStatusLabel.text = @"";
    self.dataReceivedLabel.font = [UIFont fontWithName:@"Courier" size:14.0];
    self.dataReceivedLabel.numberOfLines = 0;
    self.dataReceivedLabel.text = @"";
    self.keySerialNumberLabel.text = @"";
    self.track1MacLabel.text = @"";
    self.track2MacLabel.text = @"";

    self.track1Jis2DataLabel.numberOfLines = 0;
    self.track1Jis2DataLabel.text = @"";
    self.track1PrimaryAccountNumberLabel.numberOfLines = 0;
    self.track1PrimaryAccountNumberLabel.text = @"";
    self.track1NameLabel.numberOfLines = 0;
    self.track1NameLabel.text = @"";
    self.track1ExpirationDateLabel.numberOfLines = 0;
    self.track1ExpirationDateLabel.text = @"";
    self.track1ServiceCodeLabel.numberOfLines = 0;
    self.track1ServiceCodeLabel.text = @"";
    self.track1DiscretionaryDataLabel.numberOfLines = 0;
    self.track1DiscretionaryDataLabel.text = @"";

    self.track2PrimaryAccountNumberLabel.numberOfLines = 0;
    self.track2PrimaryAccountNumberLabel.text = @"";
    self.track2ExpirationDateLabel.numberOfLines = 0;
    self.track2ExpirationDateLabel.text = @"";
    self.track2ServiceCodeLabel.numberOfLines = 0;
    self.track2ServiceCodeLabel.text = @"";
    self.track2DiscretionaryDataLabel.numberOfLines = 0;
    self.track2DiscretionaryDataLabel.text = @"";

    // Initialize the DUKPT receiver object.
    _dukptReceiver = [[ACRDukptReceiver alloc] init];

    // Set the key serial number.
    [_dukptReceiver setKeySerialNumber:_iksn];

    // Load the initial key.
    [_dukptReceiver loadInitialKey:_ipek];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (IBAction)clearData:(id)sender {

    _swipeCount = 0;

    self.swipeCountLabel.text = @"0";
    self.batteryStatusLabel.text = @"";
    self.dataReceivedLabel.text = @"";
    self.keySerialNumberLabel.text = @"";
    self.track1MacLabel.text = @"";
    self.track2MacLabel.text = @"";

    self.track1Jis2DataLabel.text = @"";
    self.track1PrimaryAccountNumberLabel.text = @"";
    self.track1NameLabel.text = @"";
    self.track1ExpirationDateLabel.text = @"";
    self.track1ServiceCodeLabel.text = @"";
    self.track1DiscretionaryDataLabel.text = @"";

    self.track2PrimaryAccountNumberLabel.text = @"";
    self.track2ExpirationDateLabel.text = @"";
    self.track2ServiceCodeLabel.text = @"";
    self.track2DiscretionaryDataLabel.text = @"";

    [self.tableView reloadData];
}

#pragma mark - Table View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AboutReader"]) {

        AJDReaderViewController *readerViewController = [segue destinationViewController];
        [readerViewController setDelegate:self];

    } else if ([[segue identifier] isEqualToString:@"ReaderId"]) {

        AJDIdViewController *idViewController = [segue destinationViewController];
        [idViewController setDelegate:self];

    } else if ([[segue identifier] isEqualToString:@"CryptographicKeys"]) {

        AJDKeysViewController *keysViewController = [segue destinationViewController];
        [keysViewController setDelegate:self];
        keysViewController.masterKey = _masterKey;
        keysViewController.masterKey2 = _masterKey2;
        keysViewController.aesKey = _aesKey;

    } else if ([[segue identifier] isEqualToString:@"DukptSetup"]) {

        AJDDukptViewController *dukptViewController = [segue destinationViewController];
        [dukptViewController setDelegate:self];
        dukptViewController.iksn = _iksn;
        dukptViewController.ipek = _ipek;

    } else if ([[segue identifier] isEqualToString:@"TrackDataSetup"]) {

        AJDTrackDataViewController *trackDataViewController = [segue destinationViewController];
        [trackDataViewController setDelegate:self];

    } else if ([[segue identifier] isEqualToString:@"ICC"]) {

        AJDIccViewController *iccViewController = [segue destinationViewController];
        [iccViewController setDelegate:self];
        iccViewController.reader = _reader;

    } else if ([[segue identifier] isEqualToString:@"PICC"]) {

        AJDPiccViewController *piccViewController = [segue destinationViewController];
        [piccViewController setDelegate:self];
        piccViewController.atrString = @"";
        piccViewController.timeout = _piccTimeout;
        piccViewController.cardTypeString = [NSString stringWithFormat:@"%02lX", (unsigned long)_piccCardType];
        piccViewController.commandApduString = [self toHexString:[_piccCommandApdu bytes] length:[_piccCommandApdu length]];
        piccViewController.responseApduString = @"";
        piccViewController.rfConfigString = [self toHexString:[_piccRfConfig bytes] length:[_piccRfConfig length]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([cell.reuseIdentifier isEqualToString:@"ResetCell"]) {

        [self resetReader];

    } else if ([cell.reuseIdentifier isEqualToString:@"SleepCell"]) {

        [self setSleep];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the result.
            [self showResult];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = tableView.rowHeight;
    UILabel *label = nil;

    switch (indexPath.section) {

        case 2:
            if (indexPath.row == 0) {
                label = self.dataReceivedLabel;
            }
            break;

        case 4:
            if (indexPath.row == 0) {
                label = self.track1Jis2DataLabel;
            } else if (indexPath.row == 1) {
                label = self.track1PrimaryAccountNumberLabel;
            } else if (indexPath.row == 2) {
                label = self.track1NameLabel;
            } else if (indexPath.row == 3) {
                label = self.track1ExpirationDateLabel;
            } else if (indexPath.row == 4) {
                label = self.track1ServiceCodeLabel;
            } else if (indexPath.row == 5) {
                label = self.track1DiscretionaryDataLabel;
            }
            break;

        case 5:
            if (indexPath.row == 0) {
                label = self.track2PrimaryAccountNumberLabel;
            } else if (indexPath.row == 1) {
                label = self.track2ExpirationDateLabel;
            } else if (indexPath.row == 2) {
                label = self.track2ServiceCodeLabel;
            } else if (indexPath.row == 3) {
                label = self.track2DiscretionaryDataLabel;
            }
            break;

        default:
            break;
    }

    if (label != nil) {

        // Adjust the cell height.
        CGSize labelSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(tableView.frame.size.width - 40.0, MAXFLOAT) lineBreakMode:label.lineBreakMode];
        height += labelSize.height;
    }
    
    return height;
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

- (void)reader:(ACRAudioJackReader *)reader didSendTrackData:(ACRTrackData *)trackData {

    ACRTrack1Data *track1Data = [[ACRTrack1Data alloc] init];
    ACRTrack2Data *track2Data = [[ACRTrack2Data alloc] init];
    ACRTrack1Data *track1MaskedData = [[ACRTrack1Data alloc] init];
    ACRTrack2Data *track2MaskedData = [[ACRTrack2Data alloc] init];
    NSString *track1MacString = @"";
    NSString *track2MacString = @"";
    NSString *batteryStatusString = [self AJD_stringFromBatteryStatus:trackData.batteryStatus];
    NSString *keySerialNumberString = @"";

    // Show the track error.
    if ((trackData.track1ErrorCode != ACRTrackErrorSuccess) ||
        (trackData.track2ErrorCode != ACRTrackErrorSuccess)) {

        dispatch_async(dispatch_get_main_queue(), ^{

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The track data may be corrupted. Please swipe the card again!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        });

        goto cleanup;
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
        self.swipeCountLabel.text = [NSString stringWithFormat:@"%d", _swipeCount];

        self.batteryStatusLabel.text = batteryStatusString;
        self.keySerialNumberLabel.text = keySerialNumberString;
        self.track1MacLabel.text = track1MacString;
        self.track2MacLabel.text = track2MacString;

        self.track1Jis2DataLabel.text = track1Data.jis2Data;
        self.track1PrimaryAccountNumberLabel.text = [NSString stringWithFormat:@"%@\n%@", track1Data.primaryAccountNumber, track1MaskedData.primaryAccountNumber];
        self.track1NameLabel.text = [NSString stringWithFormat:@"%@\n%@", track1Data.name, track1MaskedData.name];
        self.track1ExpirationDateLabel.text = [NSString stringWithFormat:@"%@\n%@", track1Data.expirationDate, track1MaskedData.expirationDate];
        self.track1ServiceCodeLabel.text = [NSString stringWithFormat:@"%@\n%@", track1Data.serviceCode, track1MaskedData.serviceCode];
        self.track1DiscretionaryDataLabel.text = [NSString stringWithFormat:@"%@\n%@", track1Data.discretionaryData, track1MaskedData.discretionaryData];
        
        self.track2PrimaryAccountNumberLabel.text = [NSString stringWithFormat:@"%@\n%@", track2Data.primaryAccountNumber, track2MaskedData.primaryAccountNumber];
        self.track2ExpirationDateLabel.text = [NSString stringWithFormat:@"%@\n%@", track2Data.expirationDate, track2MaskedData.expirationDate];
        self.track2ServiceCodeLabel.text = [NSString stringWithFormat:@"%@\n%@", track2Data.serviceCode, track2MaskedData.serviceCode];
        self.track2DiscretionaryDataLabel.text = [NSString stringWithFormat:@"%@\n%@", track2Data.discretionaryData, track2MaskedData.discretionaryData];
        
        [self.tableView reloadData];
    });
}

- (void)reader:(ACRAudioJackReader *)reader didSendRawData:(const uint8_t *)rawData length:(NSUInteger)length {

    NSString *hexString = [self toHexString:rawData length:length];

    hexString = [hexString stringByAppendingString:[_reader verifyData:rawData length:length] ? @" (Checksum OK)" : @" (Checksum Error)"];

    dispatch_async(dispatch_get_main_queue(), ^{

        self.dataReceivedLabel.text = hexString;
        [self.tableView reloadData];
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

#pragma mark - Reader View Controller

- (void)readerViewControllerDidGetFirmwareVersion:(AJDReaderViewController *)readerViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Getting the firmware version..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Get the firmware version.
        _firmwareVersionReady = NO;
        _resultReady = NO;
        if (![_reader getFirmwareVersion]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the firmware version.
            [self showFirmwareVersion:readerViewController];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }];
}

- (void)readerViewControllerDidGetStatus:(AJDReaderViewController *)readerViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Getting the status..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Get the status.
        _statusReady = NO;
        _resultReady = NO;
        if (![_reader getStatus]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the status.
            [self showStatus:readerViewController];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }];
}

- (void)readerViewController:(AJDReaderViewController *)readerViewController didSetSleepTimeout:(NSUInteger)sleepTimeout {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Setting the sleep timeout..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Set the sleep timeout.
        _resultReady = NO;
        if (![_reader setSleepTimeout:sleepTimeout]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the result.
            if ([self showResult]) {

                // Get the status.
                _statusReady = NO;
                _resultReady = NO;
                if (![_reader getStatus]) {

                    // Show the request queue error.
                    [self showRequestQueueError];

                } else {

                    // Show the status.
                    [self showStatus:readerViewController];
                }
            }
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }];
}

- (void)showFirmwareVersion:(AJDReaderViewController *)readerViewController {

    [_responseCondition lock];

    // Wait for the firmware version.
    while (!_firmwareVersionReady && !_resultReady) {
        if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }

    if (_firmwareVersionReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the firmware version.
            readerViewController.firmwareVersionLabel.text = _firmwareVersion;
            [readerViewController.tableView reloadData];
        });

    } else if (_resultReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the result.
            UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:[self toErrorCodeString:_result.errorCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [resultAlert show];
        });

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the timeout.
            UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The operation timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timeoutAlert show];
        });
    }

    _firmwareVersionReady = NO;
    _resultReady = NO;

    [_responseCondition unlock];
}

- (void)showStatus:(AJDReaderViewController *)readerViewController {

    [_responseCondition lock];

    // Wait for the status.
    while (!_statusReady && !_resultReady) {
        if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }

    if (_statusReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the status.
            readerViewController.batteryLevelLabel.text = [self toBatteryLevelString:_status.batteryLevel];
            readerViewController.sleepTimeoutLabel.text = [NSString stringWithFormat:@"%lu secs", (unsigned long)_status.sleepTimeout];
            [readerViewController.tableView reloadData];
        });

    } else if (_resultReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the result.
            UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:[self toErrorCodeString:_result.errorCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [resultAlert show];
        });

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the timeout.
            UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The operation timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timeoutAlert show];
        });
    }

    _statusReady = NO;
    _resultReady = NO;

    [_responseCondition unlock];
}

- (BOOL)showResult {

    BOOL ret = NO;

    [_responseCondition lock];

    while (!_resultReady) {
        if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }

    ret = _resultReady;

    if (_resultReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the result.
            UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:[self toErrorCodeString:_result.errorCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [resultAlert show];
        });

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the timeout.
            UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The operation timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timeoutAlert show];
        });
    }

    _resultReady = NO;

    [_responseCondition unlock];

    return ret;
}

- (void)showRequestQueueError {

    dispatch_async(dispatch_get_main_queue(), ^{

        // Show the result.
        UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The request cannot be queued." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [resultAlert show];
    });
}

#pragma mark - Id View Controller

- (void)idViewControllerDidGetCustomId:(AJDIdViewController *)idViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Getting the custom ID..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Get the custom ID.
        _customIdReady = NO;
        _resultReady = NO;
        if (![_reader getCustomId]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the custom ID.
            [self showCustomId:idViewController];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }];
}

- (void)idViewController:(AJDIdViewController *)idViewController didSetCustomId:(NSString *)customId {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Setting the custom ID..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Authenticate the reader.
        [_reader authenticateWithMasterKey:[_masterKey bytes] length:[_masterKey length] completion:^(NSInteger errorCode) {

            BOOL dismissed = YES;

            if (errorCode == ACRAuthErrorSuccess) {

                uint8_t buffer[10];
                NSRange range = { 0, [customId length] };

                memset(buffer, 0, sizeof(buffer));
                [customId getBytes:buffer maxLength:sizeof(buffer) usedLength:NULL encoding:NSASCIIStringEncoding options:0 range:range remainingRange:NULL];

                // Set the custom ID.
                _resultReady = NO;
                if (![_reader setCustomId:buffer length:sizeof(buffer)]) {

                    // Show the request queue error.
                    [self showRequestQueueError];

                } else {

                    // Show the result.
                    if ([self showResult]) {

                        dismissed = NO;

                        // Set the reader to sleep.
                        _resultReady = NO;
                        if (![_reader sleep]) {

                            // Show the request queue error.
                            [self showRequestQueueError];

                        } else {

                            // Show the result.
                            [self showResult];
                        }

                        // Reset the reader to take effect.
                        [_reader resetWithCompletion:^{

                            // Get the custom ID.
                            _customIdReady = NO;
                            _resultReady = NO;
                            if (![_reader getCustomId]) {

                                // Show the request queue error.
                                [self showRequestQueueError];

                            } else {

                                // Show the custom ID.
                                [self showCustomId:idViewController];
                            }

                            // Hide the progress.
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [alert dismissWithClickedButtonIndex:0 animated:YES];
                            });
                        }];
                    }
                }

            } else if (errorCode == ACRAuthErrorTimeout) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication timeout.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The authentication timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });

            } else {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication failure.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The authentication failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });
            }

            // Hide the progress.
            if (dismissed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                });
            }
        }];
    }];
}

- (void)idViewControllerDidGetDeviceId:(AJDIdViewController *)idViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Getting the device ID..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Get the device ID.
        _deviceIdReady = NO;
        _resultReady = NO;
        if (![_reader getDeviceId]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the device ID.
            [self showDeviceId:idViewController];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }];
}

- (void)showCustomId:(AJDIdViewController *)idViewController {

    [_responseCondition lock];

    // Wait for the custom ID.
    while (!_customIdReady && !_resultReady) {
        if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }

    if (_customIdReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the custom ID.
            idViewController.customIdLabel.text = [[NSString alloc] initWithData:_customId encoding:NSASCIIStringEncoding];
            [idViewController.tableView reloadData];
        });

    } else if (_resultReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the result.
            UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:[self toErrorCodeString:_result.errorCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [resultAlert show];
        });

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the timeout.
            UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The operation timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timeoutAlert show];
        });
    }

    _customIdReady = NO;
    _resultReady = NO;
    
    [_responseCondition unlock];
}

- (void)showDeviceId:(AJDIdViewController *)idViewController {

    [_responseCondition lock];

    // Wait for the device ID.
    while (!_deviceIdReady && !_resultReady) {
        if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }

    if (_deviceIdReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the device ID.
            idViewController.deviceIdLabel.text = [self toHexString:[_deviceId bytes] length:[_deviceId length]];
            [idViewController.tableView reloadData];
        });

    } else if (_resultReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the result.
            UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:[self toErrorCodeString:_result.errorCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [resultAlert show];
        });

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the timeout.
            UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The operation timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timeoutAlert show];
        });
    }

    _deviceIdReady = NO;
    _resultReady = NO;
    
    [_responseCondition unlock];
}

#pragma mark - Keys View Controller

- (void)keysViewController:(AJDKeysViewController *)keysViewController didChangeMasterKey:(NSData *)masterKey {

    // Check the master key.
    if ([masterKey length] != 16) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The master key length is not equal to 32 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    if (![_masterKey isEqualToData:masterKey]) {

        keysViewController.masterKeyLabel.text = [AJDHex hexStringFromByteArray:masterKey];
        [keysViewController.tableView reloadData];

        // Save the master key.
        _masterKey = masterKey;
        [_defaults setObject:_masterKey forKey:@"MasterKey"];
        [_defaults synchronize];
    }
}

- (void)keysViewController:(AJDKeysViewController *)keysViewController didChangeMasterKey2:(NSData *)masterKey2 {

    // Check the new master key.
    if ([masterKey2 length] != 16) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The new master key length is not equal to 32 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    if (![_masterKey2 isEqualToData:masterKey2]) {

        keysViewController.masterKey2Label.text = [AJDHex hexStringFromByteArray:masterKey2];
        [keysViewController.tableView reloadData];

        // Save the new master key.
        _masterKey2 = masterKey2;
        [_defaults setObject:_masterKey2 forKey:@"MasterKey2"];
        [_defaults synchronize];
    }
}

- (void)keysViewController:(AJDKeysViewController *)keysViewController didChangeAesKey:(NSData *)aesKey {

    // Check the AES key.
    if ([aesKey length] != 16) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The AES key length is not equal to 32 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    if (![_aesKey isEqualToData:aesKey]) {

        keysViewController.aesKeyLabel.text = [AJDHex hexStringFromByteArray:aesKey];
        [keysViewController.tableView reloadData];

        // Save the AES key.
        _aesKey = aesKey;
        [_defaults setObject:_aesKey forKey:@"AesKey"];
        [_defaults synchronize];
    }
}

- (void)keysViewControllerDidSetMasterKey:(AJDKeysViewController *)keysViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Setting the master key..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Authenticate the reader.
        [_reader authenticateWithMasterKey:[_masterKey bytes] length:[_masterKey length] completion:^(NSInteger errorCode) {

            BOOL dismissed = YES;

            if (errorCode == ACRAuthErrorSuccess) {

                // Set the master key.
                _resultReady = NO;
                if (![_reader setMasterKey:[_masterKey2 bytes] length:[_masterKey2 length]]) {

                    // Show the request queue error.
                    [self showRequestQueueError];

                } else {

                    // Show the result.
                    if ([self showResult]) {

                        dismissed = NO;

                        // Set the reader to sleep.
                        _resultReady = NO;
                        if (![_reader sleep]) {

                            // Show the request queue error.
                            [self showRequestQueueError];

                        } else {

                            // Show the result.
                            [self showResult];
                        }

                        // Reset the reader to take effect.
                        [_reader resetWithCompletion:^{

                            // Hide the progress.
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [alert dismissWithClickedButtonIndex:0 animated:YES];
                            });
                        }];
                    }
                }
                
            } else if (errorCode == ACRAuthErrorTimeout) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication timeout.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The authentication timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });

            } else {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication failure.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The authentication failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });
            }

            // Hide the progress.
            if (dismissed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                });
            }
        }];
    }];
}

- (void)keysViewControllerDidSetAesKey:(AJDKeysViewController *)keysViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Setting the AES key..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Authenticate the reader.
        [_reader authenticateWithMasterKey:[_masterKey bytes] length:[_masterKey length] completion:^(NSInteger errorCode) {

            BOOL dismissed = YES;

            if (errorCode == ACRAuthErrorSuccess) {

                // Set the AES key.
                _resultReady = NO;
                if (![_reader setAesKey:[_aesKey bytes] length:[_aesKey length]]) {

                    // Show the request queue error.
                    [self showRequestQueueError];

                } else {

                    // Show the result.
                    if ([self showResult]) {

                        dismissed = NO;

                        // Set the reader to sleep.
                        _resultReady = NO;
                        if (![_reader sleep]) {

                            // Show the request queue error.
                            [self showRequestQueueError];

                        } else {

                            // Show the result.
                            [self showResult];
                        }

                        // Reset the reader to take effect.
                        [_reader resetWithCompletion:^{

                            // Hide the progress.
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [alert dismissWithClickedButtonIndex:0 animated:YES];
                            });
                        }];
                    }
                }

            } else if (errorCode == ACRAuthErrorTimeout) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication timeout.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The authentication timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });

            } else {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication failure.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The authentication failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });
            }

            // Hide the progress.
            if (dismissed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                });
            }
        }];
    }];
}

#pragma mark - Dukpt View Controller

- (void)dukptViewController:(AJDDukptViewController *)dukptViewController didChangeIksn:(NSData *)iksn {

    // Check the IKSN.
    if ([iksn length] != 10) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The IKSN length is not equal to 20 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    if (![_iksn isEqualToData:iksn]) {

        // Show the IKSN.
        dukptViewController.iksnLabel.text = [AJDHex hexStringFromByteArray:iksn];
        [dukptViewController.tableView reloadData];

        // Save the IKSN.
        _iksn = iksn;
        [_defaults setObject:_iksn forKey:@"IKSN"];
        [_defaults synchronize];

        // Set the key serial number.
        [_dukptReceiver setKeySerialNumber:_iksn];

        // Load the initial key.
        [_dukptReceiver loadInitialKey:_ipek];
    }
}

- (void)dukptViewController:(AJDDukptViewController *)dukptViewController didChangeIpek:(NSData *)ipek {

    // Check the IPEK.
    if ([ipek length] != 16) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The IPEK length is not equal to 32 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    if (![_ipek isEqualToData:ipek]) {

        // Show the IPEK.
        dukptViewController.ipekLabel.text = [AJDHex hexStringFromByteArray:ipek];
        [dukptViewController.tableView reloadData];

        // Save the IPEK.
        _ipek = ipek;
        [_defaults setObject:_ipek forKey:@"IPEK"];
        [_defaults synchronize];

        // Set the key serial number.
        [_dukptReceiver setKeySerialNumber:_iksn];

        // Load the initial key.
        [_dukptReceiver loadInitialKey:_ipek];
    }
}

- (void)dukptViewControllerDidGetDukptOption:(AJDDukptViewController *)dukptViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Getting the DUKPT option..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Get the DUKPT option.
        _dukptOptionReady = NO;
        _resultReady = NO;
        if (![_reader getDukptOption]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the DUKPT option.
            [self showDukptOption:dukptViewController];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }];
}

- (void)dukptViewController:(AJDDukptViewController *)dukptViewController didSetDukptOption:(BOOL)enabled {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Setting the DUKPT option..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Authenticate the reader.
        [_reader authenticateWithMasterKey:[_masterKey bytes] length:[_masterKey length] completion:^(NSInteger errorCode) {

            BOOL dismissed = YES;

            if (errorCode == ACRAuthErrorSuccess) {

                // Set the DUKPT option.
                _resultReady = NO;
                if (![_reader setDukptOption:enabled]) {

                    // Show the request queue error.
                    [self showRequestQueueError];

                } else {

                    // Show the result.
                    if ([self showResult]) {

                        dismissed = NO;

                        // Set the reader to sleep.
                        _resultReady = NO;
                        if (![_reader sleep]) {

                            // Show the request queue error.
                            [self showRequestQueueError];

                        } else {

                            // Show the result.
                            [self showResult];
                        }

                        // Reset the reader to take effect.
                        [_reader resetWithCompletion:^{

                            // Get the DUKPT option.
                            _dukptOptionReady = NO;
                            _resultReady = NO;
                            if (![_reader getDukptOption]) {

                                // Show the request queue error.
                                [self showRequestQueueError];

                            } else {

                                // Show the DUKPT option.
                                [self showDukptOption:dukptViewController];
                            }

                            // Hide the progress.
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [alert dismissWithClickedButtonIndex:0 animated:YES];
                            });
                        }];
                    }
                }

            } else if (errorCode == ACRAuthErrorTimeout) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication timeout.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The authentication timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });

            } else {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication failure.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The authentication failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });
            }
            
            // Hide the progress.
            if (dismissed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                });
            }
        }];
    }];
}

- (void)dukptViewControllerDidInitializeDukpt:(AJDDukptViewController *)dukptViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Initializing the DUKPT..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Authenticate the reader.
        [_reader authenticateWithMasterKey:[_masterKey bytes] length:[_masterKey length] completion:^(NSInteger errorCode) {

            BOOL dismissed = YES;

            if (errorCode == ACRAuthErrorSuccess) {

                // Initialize the DUKPT.
                _resultReady = NO;
                if (![_reader initializeDukptWithIksn:[_iksn bytes] iksnLength:[_iksn length] ipek:[_ipek bytes] ipekLength:[_ipek length]]) {

                    // Show the request queue error.
                    [self showRequestQueueError];

                } else {

                    // Show the result.
                    if ([self showResult]) {

                        dismissed = NO;

                        // Set the reader to sleep.
                        _resultReady = NO;
                        if (![_reader sleep]) {

                            // Show the request queue error.
                            [self showRequestQueueError];

                        } else {

                            // Show the result.
                            [self showResult];
                        }

                        // Reset the reader to take effect.
                        [_reader resetWithCompletion:^{

                            // Hide the progress.
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [alert dismissWithClickedButtonIndex:0 animated:YES];
                            });
                        }];
                    }
                }
                
            } else if (errorCode == ACRAuthErrorTimeout) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication timeout.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The authentication timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });

            } else {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication failure.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The authentication failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });
            }

            // Hide the progress.
            if (dismissed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                });
            }
        }];
    }];
}

- (void)showDukptOption:(AJDDukptViewController *)dukptViewController {

    [_responseCondition lock];

    // Wait for the DUKPT option.
    while (!_dukptOptionReady && !_resultReady) {
        if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }

    if (_dukptOptionReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the DUKPT option.
            dukptViewController.dukptSwitch.on = _dukptOption;
        });

    } else if (_resultReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the result.
            UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:[self toErrorCodeString:_result.errorCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [resultAlert show];
        });

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the timeout.
            UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The operation timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timeoutAlert show];
        });
    }

    _dukptOptionReady = NO;
    _resultReady = NO;
    
    [_responseCondition unlock];
}

#pragma mark - Track Data View Controller

- (void)trackDataViewControllerDidReset:(AJDTrackDataViewController *)trackDataViewController {
    [self resetReader];
}

- (void)trackDataViewControllerDidGetTrackDataOption:(AJDTrackDataViewController *)trackDataViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Getting the track data option..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // Get the track data option.
        _trackDataOptionReady = NO;
        _resultReady = NO;
        if (![_reader getTrackDataOption]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the track data option.
            [self AJD_showTrackDataOption:trackDataViewController];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    });
}

- (void)trackDataViewController:(AJDTrackDataViewController *)trackDataViewController didSetTrackDataOption:(ACRTrackDataOption)option {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Setting the track data option..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Reset the reader.
    [_reader resetWithCompletion:^{

        // Authenticate the reader.
        [_reader authenticateWithMasterKey:[_masterKey bytes] length:[_masterKey length] completion:^(NSInteger errorCode) {

            BOOL dismissed = YES;

            if (errorCode == ACRAuthErrorSuccess) {

                // Set the track data option.
                _resultReady = NO;
                if (![_reader setTrackDataOption:option]) {

                    // Show the request queue error.
                    [self showRequestQueueError];

                } else {

                    // Show the result.
                    if ([self showResult]) {

                        dismissed = NO;

                        // Set the reader to sleep.
                        _resultReady = NO;
                        if (![_reader sleep]) {

                            // Show the request queue error.
                            [self showRequestQueueError];
                            
                        } else {
                            
                            // Show the result.
                            [self showResult];
                        }

                        // Reset the reader to take effect.
                        [_reader resetWithCompletion:^{

                            // Get the track data option.
                            _trackDataOptionReady = NO;
                            _resultReady = NO;
                            if (![_reader getTrackDataOption]) {

                                // Show the request queue error.
                                [self showRequestQueueError];
                                
                            } else {
                                
                                // Show the track data option.
                                [self AJD_showTrackDataOption:trackDataViewController];
                            }

                            // Hide the progress.
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [alert dismissWithClickedButtonIndex:0 animated:YES];
                            });
                        }];
                    }
                }

            } else if (errorCode == ACRAuthErrorTimeout) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication timeout.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The authentication timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });

            } else {

                dispatch_async(dispatch_get_main_queue(), ^{

                    // Show the authentication failure.
                    UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The authentication failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [timeoutAlert show];
                });
            }
            
            // Hide the progress.
            if (dismissed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                });
            }
        }];
    }];
}

#pragma mark - Icc View Controller

- (void)iccViewControllerDidReset:(AJDIccViewController *)iccViewController {
    [self resetReader];
}

#pragma mark - Picc View Controller

- (void)piccViewController:(AJDPiccViewController *)piccViewController didChangeTimeout:(NSString *)timeoutString {

    NSUInteger timeout = [timeoutString integerValue];

    if (timeout != _piccTimeout) {

        _piccTimeout = timeout;
        _piccTimeoutString = [NSString stringWithFormat:@"%lu", (unsigned long)timeout];
        piccViewController.timeout = timeout;
        piccViewController.timeoutLabel.text = [NSString stringWithFormat:@"%lu secs", (unsigned long)timeout];
        [piccViewController.tableView reloadData];
        [_defaults setObject:_piccTimeoutString forKey:@"PiccTimeout"];
        [_defaults synchronize];
    }
}

- (void)piccViewController:(AJDPiccViewController *)piccViewController didChangeCardType:(NSString *)cardTypeString {

    uint8_t cardType[] = { 0 };

    [self toByteArray:cardTypeString buffer:cardType bufferSize:sizeof(cardType)];

    if (cardType[0] != (uint8_t) _piccCardType) {

        _piccCardType = cardType[0];
        _piccCardTypeString = [NSString stringWithFormat:@"%02X", cardType[0]];
        piccViewController.cardTypeString = _piccCardTypeString;
        piccViewController.cardTypeLabel.text = _piccCardTypeString;
        [piccViewController.tableView reloadData];
        [_defaults setObject:_piccCardTypeString forKey:@"PiccCardType"];
        [_defaults synchronize];
    }
}

- (void)piccViewController:(AJDPiccViewController *)piccViewController didChangeCommandApdu:(NSString *)commandApduString {

    NSData *commandApdu = [self toByteArray:commandApduString];

    if (![commandApdu isEqualToData:_piccCommandApdu]) {

        _piccCommandApdu = commandApdu;
        _piccCommandApduString = [self toHexString:[commandApdu bytes] length:[commandApdu length]];
        piccViewController.commandApduString = _piccCommandApduString;
        piccViewController.commandApduLabel.text = _piccCommandApduString;
        [piccViewController.tableView reloadData];
        [_defaults setObject:_piccCommandApduString forKey:@"PiccCommandApdu"];
        [_defaults synchronize];
    }
}

- (void)piccViewController:(AJDPiccViewController *)piccViewController didChangeRfConfig:(NSString *)rfConfigString {

    NSData *rfConfig = [self toByteArray:rfConfigString];

    if ([rfConfig length] != 19) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The RF configuration length is not equal to 19." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

    } else {

        if (![rfConfig isEqualToData:_piccRfConfig]) {

            _piccRfConfig = rfConfig;
            _piccRfConfigString = [self toHexString:[rfConfig bytes] length:[rfConfig length]];
            piccViewController.rfConfigString = _piccRfConfigString;
            piccViewController.rfConfigLabel.text = _piccRfConfigString;
            [piccViewController.tableView reloadData];
            [_defaults setObject:_piccRfConfigString forKey:@"PiccRfConfig"];
            [_defaults synchronize];
        }
    }
}

- (void)piccViewControllerDidReset:(AJDPiccViewController *)piccViewController {
    [self resetReader];
}

- (void)piccViewControllerDidPowerOn:(AJDPiccViewController *)piccViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Powering on the PICC..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Clear the ATR.
    piccViewController.atrLabel.text = @"";
    [piccViewController.tableView reloadData];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // Power on the PICC.
        _piccAtrReady = NO;
        _resultReady = NO;
        if (![_reader piccPowerOnWithTimeout:_piccTimeout cardType:_piccCardType]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the PICC ATR.
            [self showPiccAtr:piccViewController];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    });
}

- (void)showPiccAtr:(AJDPiccViewController *)piccViewController {

    [_responseCondition lock];

    // Wait for the PICC ATR.
    while (!_piccAtrReady && !_resultReady) {
        if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }

    if (_piccAtrReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the PICC ATR.
            piccViewController.atrLabel.text = [self toHexString:[_piccAtr bytes] length:[_piccAtr length]];
            [piccViewController.tableView reloadData];
        });

    } else if (_resultReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the result.
            UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:[self toErrorCodeString:_result.errorCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [resultAlert show];
        });

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the timeout.
            UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The operation timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timeoutAlert show];
        });
    }

    _piccAtrReady = NO;
    _resultReady = NO;
    
    [_responseCondition unlock];
}

- (void)piccViewControllerDidPowerOff:(AJDPiccViewController *)piccViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Powering off the PICC..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // Power off the PICC.
        _resultReady = NO;
        if (![_reader piccPowerOff]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the result.
            [self showResult];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    });
}

- (void)piccViewControllerDidTransmit:(AJDPiccViewController *)piccViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Transmitting the command APDU..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    // Clear the response APDU.
    piccViewController.responseApduLabel.text = @"";
    [piccViewController.tableView reloadData];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // Transmit the command APDU.
        _piccResponseApduReady = NO;
        _resultReady = NO;
        if (![_reader piccTransmitWithTimeout:_piccTimeout commandApdu:[_piccCommandApdu bytes] length:[_piccCommandApdu length]]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the PICC response APDU.
            [self showPiccResponseApdu:piccViewController];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    });
}

- (void)showPiccResponseApdu:(AJDPiccViewController *)piccViewController {

    [_responseCondition lock];

    // Wait for the PICC response APDU.
    while (!_piccResponseApduReady && !_resultReady) {
        if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }

    if (_piccResponseApduReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the PICC response APDU.
            piccViewController.responseApduLabel.text = [self toHexString:[_piccResponseApdu bytes] length:[_piccResponseApdu length]];
            [piccViewController.tableView reloadData];
        });

    } else if (_resultReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the result.
            UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:[self toErrorCodeString:_result.errorCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [resultAlert show];
        });

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the timeout.
            UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The operation timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timeoutAlert show];
        });
    }
    
    _piccResponseApduReady = NO;
    _resultReady = NO;
    
    [_responseCondition unlock];
}

- (void)piccViewControllerDidSetRfConfig:(AJDPiccViewController *)piccViewController {

    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Setting the RF configuration..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // Set the PICC RF configuration.
        _resultReady = NO;
        if (![_reader setPiccRfConfig:[_piccRfConfig bytes] length:[_piccRfConfig length]]) {

            // Show the request queue error.
            [self showRequestQueueError];

        } else {

            // Show the result.
            [self showResult];
        }

        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    });
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
 * Shows the track data option.
 * @param trackDataViewController the track data view controller.
 */
- (void)AJD_showTrackDataOption:(AJDTrackDataViewController *)trackDataViewController {

    [_responseCondition lock];

    // Wait for the track data option.
    while (!_trackDataOptionReady && !_resultReady) {
        if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }

    if (_trackDataOptionReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the track data option.
            trackDataViewController.encryptedTrack1Switch.on = (_trackDataOption & ACRTrackDataOptionEncryptedTrack1) ? YES : NO;

            trackDataViewController.encryptedTrack2Switch.on = (_trackDataOption & ACRTrackDataOptionEncryptedTrack2) ? YES : NO;

            trackDataViewController.maskedTrack1Switch.on = (_trackDataOption & ACRTrackDataOptionMaskedTrack1) ? YES : NO;

            trackDataViewController.maskedTrack2Switch.on = (_trackDataOption & ACRTrackDataOptionMaskedTrack2) ? YES : NO;
        });

    } else if (_resultReady) {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the result.
            UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:[self toErrorCodeString:_result.errorCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [resultAlert show];
        });

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{

            // Show the timeout.
            UIAlertView *timeoutAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The operation timed out." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timeoutAlert show];
        });
    }
    
    _trackDataOptionReady = NO;
    _resultReady = NO;
    
    [_responseCondition unlock];
}

@end
