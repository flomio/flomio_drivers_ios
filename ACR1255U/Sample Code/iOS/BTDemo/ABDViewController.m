/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "ABDViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <ACSBluetooth/ACSBluetooth.h>
#import "ABDHex.h"
#import "ABDReaderViewController.h"
#import "ABDDeviceInfoViewController.h"
#import "ABDTxPowerViewController.h"

@interface ABDViewController () <UIAlertViewDelegate, CBCentralManagerDelegate, ABTBluetoothReaderManagerDelegate, ABTBluetoothReaderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *readerLabel;
@property (weak, nonatomic) IBOutlet UILabel *masterKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *atrLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *commandApduLabel;
@property (weak, nonatomic) IBOutlet UILabel *responseApduLabel;
@property (weak, nonatomic) IBOutlet UILabel *escapeCommandLabel;
@property (weak, nonatomic) IBOutlet UILabel *escapeResponseLabel;
@property (weak, nonatomic) IBOutlet UILabel *txPowerLabel;

- (IBAction)clearData:(id)sender;

@end

@implementation ABDViewController {

    CBCentralManager *_centralManager;
    CBPeripheral *_peripheral;
    NSMutableArray *_peripherals;
    ABTBluetoothReaderManager *_bluetoothReaderManager;
    ABTBluetoothReader *_bluetoothReader;
    __weak ABDReaderViewController *_readerViewController;
    __weak ABDDeviceInfoViewController *_deviceInfoViewController;

    NSUserDefaults *_defaults;
    NSData *_masterKey;
    NSData *_commandApdu;
    NSData *_escapeCommand;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _peripherals = [NSMutableArray array];
    _bluetoothReaderManager = [[ABTBluetoothReaderManager alloc] init];
    _bluetoothReaderManager.delegate = self;

    _defaults = [NSUserDefaults standardUserDefaults];

    // Load the master key.
    _masterKey = [_defaults dataForKey:@"MasterKey"];
    if (_masterKey == nil) {
        _masterKey = [ABDHex byteArrayFromHexString:@"FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF"];
    }
    self.masterKeyLabel.text = [ABDHex hexStringFromByteArray:_masterKey];

    // Load the command APDU.
    _commandApdu = [_defaults dataForKey:@"CommandApdu"];
    if (_commandApdu == nil) {
        _commandApdu = [ABDHex byteArrayFromHexString:@"00 84 00 00 08"];
    }
    self.commandApduLabel.text = [ABDHex hexStringFromByteArray:_commandApdu];

    // Load the escape command.
    _escapeCommand = [_defaults dataForKey:@"EscapeCommand"];
    if (_escapeCommand == nil) {
        _escapeCommand = [ABDHex byteArrayFromHexString:@"04 00"];
    }
    self.escapeCommandLabel.text = [ABDHex hexStringFromByteArray:_escapeCommand];

    self.readerLabel.text = @"";
    self.atrLabel.text = @"";
    self.cardStatusLabel.text = @"";
    self.batteryStatusLabel.text = @"";
    self.batteryLevelLabel.text = @"";
    self.responseApduLabel.text = @"";
    self.escapeResponseLabel.text = @"";

    self.masterKeyLabel.numberOfLines = 0;
    self.atrLabel.numberOfLines = 0;
    self.commandApduLabel.numberOfLines = 0;
    self.responseApduLabel.numberOfLines = 0;
    self.escapeCommandLabel.numberOfLines = 0;
    self.escapeResponseLabel.numberOfLines = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clearData:(id)sender {

    self.atrLabel.text = @"";
    self.cardStatusLabel.text = @"";
    self.batteryStatusLabel.text = @"";
    self.batteryLevelLabel.text = @"";
    self.responseApduLabel.text = @"";
    self.escapeResponseLabel.text = @"";

    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowReaders"]) {

        UINavigationController *controller = segue.destinationViewController;
        _readerViewController = (ABDReaderViewController *) controller.topViewController;
        _readerViewController.peripherals = _peripherals;
        _readerViewController.peripheral = nil;

        // Clear the reader name.
        self.readerLabel.text = @"";
        [self.tableView reloadData];

        // Clear the data.
        [self clearData:nil];

        // Detach the peripheral.
        [_bluetoothReader detach];

        // Disconnect the peripheral.
        if (_peripheral != nil) {

            [_centralManager cancelPeripheralConnection:_peripheral];
            _peripheral = nil;
        }

        // Remove all peripherals.
        [_peripherals removeAllObjects];

        // Scan the peripherals.
        [_centralManager scanForPeripheralsWithServices:nil options:nil];

    } else if ([segue.identifier isEqualToString:@"ShowDeviceInfo"]) {

        _deviceInfoViewController = segue.destinationViewController;

        // Get the device information.
        [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoSystemId];
        [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoModelNumberString];
        [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoSerialNumberString];
        [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoFirmwareRevisionString];
        [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoHardwareRevisionString];
        [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoManufacturerNameString];

    } else if ([segue.identifier isEqualToString:@"ShowTxPower"]) {

        ABDTxPowerViewController *txPowerViewController = (ABDTxPowerViewController *) segue.destinationViewController;

        txPowerViewController.bluetoothReader = _bluetoothReader;
        txPowerViewController.txPowerLabel = self.txPowerLabel;
    }
}

- (IBAction)unwindToMain:(UIStoryboardSegue *)segue {

    ABDReaderViewController *readerViewController = segue.sourceViewController;

    // Stop the scan.
    [_centralManager stopScan];

    // If the peripheral is selected, then connect it.
    if (readerViewController.peripheral != nil) {

        // Store the peripheral.
        _peripheral = readerViewController.peripheral;

        // Show the peripheral.
        self.readerLabel.text = _peripheral.name;
        [self.tableView reloadData];

        // Connect the peripheral.
        [_centralManager connectPeripheral:_peripheral options:nil];
    }
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if ([cell.reuseIdentifier isEqualToString:@"MasterKey"]) {

        // Modify the master key.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Master Key" message:@"Enter the HEX string:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 0;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = [ABDHex hexStringFromByteArray:_masterKey];

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"CommandApdu"]) {

        // Modify the command APDU.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Command APDU" message:@"Enter the HEX string:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 1;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = [ABDHex hexStringFromByteArray:_commandApdu];

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"EscapeCommand"]) {

        // Modify the escape command.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Escape Command" message:@"Enter the HEX string:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 2;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = [ABDHex hexStringFromByteArray:_escapeCommand];

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"UseDefaultKey"]) {

        self.masterKeyLabel.text = @"FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF";
        _masterKey = [ABDHex byteArrayFromHexString:self.masterKeyLabel.text];

        // Save the master key.
        [_defaults setObject:_masterKey forKey:@"MasterKey"];
        [_defaults synchronize];

    } else if ([cell.reuseIdentifier isEqualToString:@"UseDefaultKey2"]) {

        self.masterKeyLabel.text = @"41 43 52 31 32 35 35 55 2D 4A 31 20 41 75 74 68";
        _masterKey = [ABDHex byteArrayFromHexString:self.masterKeyLabel.text];

        // Save the master key.
        [_defaults setObject:_masterKey forKey:@"MasterKey"];
        [_defaults synchronize];

    } else if ([cell.reuseIdentifier isEqualToString:@"GetBatteryStatus"]) {

        if ([_bluetoothReader isKindOfClass:[ABTAcr3901us1Reader class]]) {

            ABTAcr3901us1Reader *reader = (ABTAcr3901us1Reader *) _bluetoothReader;

            // Clear the battery status.
            self.batteryStatusLabel.text = @"";
            [self.tableView reloadData];

            // Get the battery status.
            [reader getBatteryStatus];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"AuthenticateReader"]) {

        // Authenticate the reader.
        [_bluetoothReader authenticateWithMasterKey:_masterKey];

    } else if ([cell.reuseIdentifier isEqualToString:@"GetBatteryLevel"]) {

        if ([_bluetoothReader isKindOfClass:[ABTAcr1255uj1Reader class]]) {

            ABTAcr1255uj1Reader *reader = (ABTAcr1255uj1Reader *) _bluetoothReader;

            // Clear the battery level.
            self.batteryLevelLabel.text = @"";
            [self.tableView reloadData];

            // Get the battery level.
            [reader getBatteryLevel];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"EnablePolling"]) {

        if ([_bluetoothReader isKindOfClass:[ABTAcr1255uj1Reader class]]) {

            uint8_t command[] = { 0xE0, 0x00, 0x00, 0x40, 0x01 };

            [_bluetoothReader transmitEscapeCommand:command length:sizeof(command)];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"DisablePolling"]) {

        if ([_bluetoothReader isKindOfClass:[ABTAcr1255uj1Reader class]]) {

            uint8_t command[] = { 0xE0, 0x00, 0x00, 0x40, 0x00 };

            [_bluetoothReader transmitEscapeCommand:command length:sizeof(command)];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"PowerOnCard"]) {

        // Clear the ATR string.
        self.atrLabel.text = @"";
        [self.tableView reloadData];

        // Power on the card.
        [_bluetoothReader powerOnCard];

    } else if ([cell.reuseIdentifier isEqualToString:@"PowerOffCard"]) {

        // Power off the card.
        [_bluetoothReader powerOffCard];

    } else if ([cell.reuseIdentifier isEqualToString:@"GetCardStatus"]) {

        // Clear the card status.
        self.cardStatusLabel.text = @"";
        [self.tableView reloadData];

        // Get the card status.
        [_bluetoothReader getCardStatus];

    } else if ([cell.reuseIdentifier isEqualToString:@"TransmitApdu"]) {

        // Clear the response APDU.
        self.responseApduLabel.text = @"";
        [self.tableView reloadData];

        // Transmit the APDU.
        [_bluetoothReader transmitApdu:_commandApdu];

    } else if ([cell.reuseIdentifier isEqualToString:@"TransmitEscapeCommand"]) {

        // Clear the escape response.
        self.escapeResponseLabel.text = @"";
        [self.tableView reloadData];

        // Transmit the escape command.
        [_bluetoothReader transmitEscapeCommand:_escapeCommand];

    } else if ([cell.reuseIdentifier isEqualToString:@"About"]) {

        // Show the version information.
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"About %@", name] message:[NSString stringWithFormat:@"Version %@ (%@)", version, build] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = tableView.rowHeight;
    UILabel *label = nil;

    switch (indexPath.section) {

        case 0:
            if (indexPath.row == 2) {
                label = self.masterKeyLabel;
            }
            break;

        case 1:
            if (indexPath.row == 0) {
                label = self.atrLabel;
            }
            break;

        case 2:
            if (indexPath.row == 0) {
                label = self.commandApduLabel;
            } else if (indexPath.row == 1) {
                label = self.responseApduLabel;
            }
            break;

        case 3:
            if (indexPath.row == 0) {
                label = self.escapeCommandLabel;
            } else if (indexPath.row == 1) {
                label = self.escapeResponseLabel;
            }
            break;

        default:
            break;
    }

    if (label != nil) {

        // Adjust the cell height.
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
        CGSize labelSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(tableView.frame.size.width - 40.0, MAXFLOAT) lineBreakMode:label.lineBreakMode];

        // Set the row height to 44 if it is less than zero (iOS 8.0).
        if (height < 0) {
            height = 44;
        }

        height += labelSize.height;
#else
        CGRect labelRect = [label.text boundingRectWithSize:CGSizeMake(tableView.frame.size.width - 40.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil];

        // Set the row height to 44 if it is less than zero (iOS 8.0).
        if (height < 0) {
            height = 44;
        }

        height += labelRect.size.height;
#endif
    }

    return height;
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSData *masterKey = nil;
    NSData *commandApdu = nil;
    NSData *escapeCommand = nil;

    switch (alertView.tag) {

        case 0: // Master key.
            masterKey = [ABDHex byteArrayFromHexString:[alertView textFieldAtIndex:0].text];
            if (![_masterKey isEqualToData:masterKey]) {

                _masterKey = masterKey;
                self.masterKeyLabel.text = [ABDHex hexStringFromByteArray:_masterKey];

                // Save the master key.
                [_defaults setObject:_masterKey forKey:@"MasterKey"];
                [_defaults synchronize];
            }
            break;

        case 1: // Command APDU.
            commandApdu = [ABDHex byteArrayFromHexString:[alertView textFieldAtIndex:0].text];
            if (![_commandApdu isEqualToData:commandApdu]) {

                _commandApdu = commandApdu;
                self.commandApduLabel.text = [ABDHex hexStringFromByteArray:_commandApdu];

                // Save the command APDU.
                [_defaults setObject:_commandApdu forKey:@"CommandApdu"];
                [_defaults synchronize];
            }
            break;

        case 2: // Escape command.
            escapeCommand = [ABDHex byteArrayFromHexString:[alertView textFieldAtIndex:0].text];
            if (![_escapeCommand isEqualToData:escapeCommand]) {

                _escapeCommand = escapeCommand;
                self.escapeCommandLabel.text = [ABDHex hexStringFromByteArray:_escapeCommand];

                // Save the escape command.
                [_defaults setObject:_escapeCommand forKey:@"EscapeCommand"];
                [_defaults synchronize];
            }
            break;

        default:
            break;
    }
}

#pragma mark - Central Manager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

    static BOOL firstRun = YES;
    NSString *message = nil;

    switch (central.state) {

        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateResetting:
            message = @"The update is being started. Please wait until Bluetooth is ready.";
            break;

        case CBCentralManagerStateUnsupported:
            message = @"This device does not support Bluetooth low energy.";
            break;

        case CBCentralManagerStateUnauthorized:
            message = @"This app is not authorized to use Bluetooth low energy.";
            break;

        case CBCentralManagerStatePoweredOff:
            if (!firstRun) {
                message = @"You must turn on Bluetooth in Settings in order to use the reader.";
            }
            break;

        default:
            break;
    }

    if (message != nil) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }

    firstRun = NO;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    // If the peripheral is not found, then add it to the array.
    if ([_peripherals indexOfObject:peripheral] == NSNotFound) {

        // Add the peripheral to the array.
        [_peripherals addObject:peripheral];

        // Show the peripheral.
        if (_readerViewController != nil) {
            [_readerViewController.tableView reloadData];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    // Detect the Bluetooth reader.
    [_bluetoothReaderManager detectReaderWithPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    // Show the error
    if (error != nil) {
        [self ABD_showError:error];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The reader is disconnected successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - Bluetooth Reader Manager

- (void)bluetoothReaderManager:(ABTBluetoothReaderManager *)bluetoothReaderManager didDetectReader:(ABTBluetoothReader *)reader peripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Store the Bluetooth reader.
        _bluetoothReader = reader;
        _bluetoothReader.delegate = self;

        // Attach the peripheral to the Bluetooth reader.
        [_bluetoothReader attachPeripheral:peripheral];
    }
}

#pragma mark - Bluetooth Reader

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didAttachPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The reader is attached to the peripheral successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnDeviceInfo:(NSObject *)deviceInfo type:(ABTBluetoothReaderDeviceInfo)type error:(NSError *)error {

    // Show the error
    if (error != nil) {

        [self ABD_showError:error];

    } else {

        if (_deviceInfoViewController != nil) {

            switch (type) {

                case ABTBluetoothReaderDeviceInfoSystemId:
                    // Show the system ID.
                    _deviceInfoViewController.systemIdLabel.text = [ABDHex hexStringFromByteArray:(NSData *)deviceInfo];
                    break;

                case ABTBluetoothReaderDeviceInfoModelNumberString:
                    // Show the model number.
                    _deviceInfoViewController.modelNumberLabel.text = (NSString *) deviceInfo;
                    break;

                case ABTBluetoothReaderDeviceInfoSerialNumberString:
                    // Show the serial number.
                    _deviceInfoViewController.serialNumberLabel.text = (NSString *) deviceInfo;
                    break;

                case ABTBluetoothReaderDeviceInfoFirmwareRevisionString:
                    // Show the firmware revision.
                    _deviceInfoViewController.firmwareRevisionLabel.text = (NSString *) deviceInfo;
                    break;

                case ABTBluetoothReaderDeviceInfoHardwareRevisionString:
                    // Show the hardware revision.
                    _deviceInfoViewController.hardwareRevisionLabel.text = (NSString *) deviceInfo;
                    break;

                case ABTBluetoothReaderDeviceInfoManufacturerNameString:
                    // Show the manufacturer name.
                    _deviceInfoViewController.manufacturerNameLabel.text = (NSString *) deviceInfo;
                    break;
                    
                default:
                    break;
            }

            [_deviceInfoViewController.tableView reloadData];
        }
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didAuthenticateWithError:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The reader is authenticated successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnAtr:(NSData *)atr error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the ATR string.
        self.atrLabel.text = [ABDHex hexStringFromByteArray:atr];
        [self.tableView reloadData];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didPowerOffCardWithError:(NSError *)error {

    // Show the error
    if (error != nil) {
        [self ABD_showError:error];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnCardStatus:(ABTBluetoothReaderCardStatus)cardStatus error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the card status.
        self.cardStatusLabel.text = [self ABD_stringFromCardStatus:cardStatus];
        [self.tableView reloadData];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnResponseApdu:(NSData *)apdu error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the response APDU.
        self.responseApduLabel.text = [ABDHex hexStringFromByteArray:apdu];
        [self.tableView reloadData];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnEscapeResponse:(NSData *)response error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the escape response.
        self.escapeResponseLabel.text = [ABDHex hexStringFromByteArray:response];
        [self.tableView reloadData];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeCardStatus:(ABTBluetoothReaderCardStatus)cardStatus error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the card status.
        self.cardStatusLabel.text = [self ABD_stringFromCardStatus:cardStatus];
        [self.tableView reloadData];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeBatteryStatus:(ABTBluetoothReaderBatteryStatus)batteryStatus error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the battery status.
        self.batteryStatusLabel.text = [self ABD_stringFromBatteryStatus:batteryStatus];
        [self.tableView reloadData];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeBatteryLevel:(NSUInteger)batteryLevel error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the battery level.
        self.batteryLevelLabel.text = [NSString stringWithFormat:@"%lu%%", (unsigned long) batteryLevel];
        [self.tableView reloadData];
    }
}

#pragma mark - Private Methods

/**
 * Returns the description from the card status.
 * @param cardStatus the card status.
 * @return the description.
 */
- (NSString *)ABD_stringFromCardStatus:(ABTBluetoothReaderCardStatus)cardStatus {

    NSString *string = nil;

    switch (cardStatus) {

        case ABTBluetoothReaderCardStatusUnknown:
            string = @"Unknown";
            break;

        case ABTBluetoothReaderCardStatusAbsent:
            string = @"Absent";
            break;

        case ABTBluetoothReaderCardStatusPresent:
            string = @"Present";
            break;

        case ABTBluetoothReaderCardStatusPowered:
            string = @"Powered";
            break;

        case ABTBluetoothReaderCardStatusPowerSavingMode:
            string = @"Power Saving Mode";
            break;

        default:
            string = @"Unknown";
            break;
    }

    return string;
}

/**
 * Returns the description from the battery status.
 * @param batteryStatus the battery status.
 * @return the description.
 */
- (NSString *)ABD_stringFromBatteryStatus:(ABTBluetoothReaderBatteryStatus)batteryStatus {

    NSString *string = nil;

    switch (batteryStatus) {

        case ABTBluetoothReaderBatteryStatusNone:
            string = @"No Battery";
            break;

        case ABTBluetoothReaderBatteryStatusFull:
            string = @"Full";
            break;

        case ABTBluetoothReaderBatteryStatusUsbPlugged:
            string = @"USB Plugged";
            break;

        default:
            string = @"Low";
            break;
    }

    return string;
}

/**
 * Shows the error.
 * @param error the error.
 */
- (void)ABD_showError:(NSError *)error {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error %ld", (long)[error code]] message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
