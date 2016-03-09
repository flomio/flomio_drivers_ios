/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "ABDAppDelegate.h"
#import <IOBluetooth/IOBluetooth.h>
#import <ACSBluetooth/ACSBluetooth.h>
#import "ABDHex.h"

@interface ABDAppDelegate () <CBCentralManagerDelegate, ABTBluetoothReaderManagerDelegate, ABTBluetoothReaderDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *readersTableView;
@property (weak) IBOutlet NSTextField *masterKeyTextField;
@property (weak) IBOutlet NSTextField *atrTextField;
@property (weak) IBOutlet NSTextField *cardStatusLabel;
@property (weak) IBOutlet NSTextField *batteryStatusLabel;
@property (weak) IBOutlet NSTextField *batteryLevelLabel;
@property (weak) IBOutlet NSTextField *manufacturerNameTextField;
@property (weak) IBOutlet NSTextField *firmwareRevisionTextField;
@property (weak) IBOutlet NSTextField *modelNumberTextField;
@property (weak) IBOutlet NSTextField *serialNumberTextField;
@property (weak) IBOutlet NSTextField *systemIdTextField;
@property (weak) IBOutlet NSTextField *hardwareRevisionTextField;
@property (weak) IBOutlet NSTextField *commandApduTextField;
@property (weak) IBOutlet NSTextField *responseApduTextField;
@property (weak) IBOutlet NSTextField *escapeCommandTextField;
@property (weak) IBOutlet NSTextField *escapeResponseTextField;
@property (weak) IBOutlet NSButton *startScanButton;
@property (weak) IBOutlet NSButton *stopScanButton;
@property (weak) IBOutlet NSButton *connectButton;
@property (weak) IBOutlet NSButton *disconnectButton;
@property (weak) IBOutlet NSButton *authenticateButton;
@property (weak) IBOutlet NSButton *getDeviceInfoButton;
@property (weak) IBOutlet NSButton *powerOnCardButton;
@property (weak) IBOutlet NSButton *powerOffCardButton;
@property (weak) IBOutlet NSButton *getCardStatusButton;
@property (weak) IBOutlet NSButton *getBatteryStatusButton;
@property (weak) IBOutlet NSButton *getBatteryLevelButton;
@property (weak) IBOutlet NSButton *transmitApduButton;
@property (weak) IBOutlet NSButton *enablePollingButton;
@property (weak) IBOutlet NSButton *disablePollingButton;
@property (weak) IBOutlet NSButton *transmitEscapeCommandButton;
@property (weak) IBOutlet NSPopUpButton *txPowerPopUpButton;

- (IBAction)clearData:(id)sender;
- (IBAction)startScan:(id)sender;
- (IBAction)stopScan:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)authenticate:(id)sender;
- (IBAction)setDefaultMasterKeyForAcr3901us1:(id)sender;
- (IBAction)setDefaultMasterKeyForAcr1255uj1:(id)sender;
- (IBAction)getDeviceInfo:(id)sender;
- (IBAction)getBatteryStatus:(id)sender;
- (IBAction)getBatteryLevel:(id)sender;
- (IBAction)enablePolling:(id)sender;
- (IBAction)disablePolling:(id)sender;
- (IBAction)getCardStatus:(id)sender;
- (IBAction)powerOnCard:(id)sender;
- (IBAction)powerOffCard:(id)sender;
- (IBAction)transmitApdu:(id)sender;
- (IBAction)transmitEscapeCommand:(id)sender;
- (IBAction)setTxPower:(id)sender;

@end

@implementation ABDAppDelegate {

    CBCentralManager *_centralManager;
    CBPeripheral *_peripheral;
    NSMutableArray *_peripherals;
    ABTBluetoothReaderManager *_bluetoothReaderManager;
    ABTBluetoothReader *_bluetoothReader;

    NSUserDefaults *_defaults;
    NSData *_masterKey;
    NSData *_commandApdu;
    NSData *_escapeCommand;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _peripherals = [NSMutableArray array];

    _bluetoothReaderManager = [[ABTBluetoothReaderManager alloc] init];
    _bluetoothReaderManager.delegate = self;

    [self.readersTableView setDataSource:self];
    [self.readersTableView setDelegate:self];

    _defaults = [NSUserDefaults standardUserDefaults];

    // Load the master key.
    _masterKey = [_defaults dataForKey:@"MasterKey"];
    if (_masterKey == nil) {
        _masterKey = [ABDHex byteArrayFromHexString:@"FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF"];
    }
    [self.masterKeyTextField setStringValue:[ABDHex hexStringFromByteArray:_masterKey]];

    // Load the command APDU.
    _commandApdu = [_defaults dataForKey:@"CommandApdu"];
    if (_commandApdu == nil) {
        _commandApdu = [ABDHex byteArrayFromHexString:@"00 84 00 00 08"];
    }
    [self.commandApduTextField setStringValue:[ABDHex hexStringFromByteArray:_commandApdu]];

    // Load the escape command.
    _escapeCommand = [_defaults dataForKey:@"EscapeCommand"];
    if (_escapeCommand == nil) {
        _escapeCommand = [ABDHex byteArrayFromHexString:@"04 00"];
    }
    [self.escapeCommandTextField setStringValue:[ABDHex hexStringFromByteArray:_escapeCommand]];

    [self.stopScanButton setEnabled:NO];
    [self.connectButton setEnabled:NO];
    [self.disconnectButton setEnabled:NO];
    [self.authenticateButton setEnabled:NO];
    [self.getDeviceInfoButton setEnabled:NO];
    [self.powerOnCardButton setEnabled:NO];
    [self.powerOffCardButton setEnabled:NO];
    [self.getCardStatusButton setEnabled:NO];
    [self.getBatteryStatusButton setEnabled:NO];
    [self.getBatteryLevelButton setEnabled:NO];
    [self.enablePollingButton setEnabled:NO];
    [self.disablePollingButton setEnabled:NO];
    [self.transmitApduButton setEnabled:NO];
    [self.transmitEscapeCommandButton setEnabled:NO];
    [self.txPowerPopUpButton setEnabled:NO];

    [self.cardStatusLabel setStringValue:@""];
    [self.batteryStatusLabel setStringValue:@""];
    [self.batteryLevelLabel setStringValue:@""];
}

- (void)applicationWillTerminate:(NSNotification *)notification {

    NSData *masterKey = nil;
    NSData *commandApdu = nil;
    NSData *escapeCommand = nil;

    // Disconnect the peripheral.
    if (_peripheral != nil) {

        [_centralManager cancelPeripheralConnection:_peripheral];
        _peripheral = nil;
    }

    // Save the master key.
    masterKey = [ABDHex byteArrayFromHexString:[self.masterKeyTextField stringValue]];
    if (![_masterKey isEqualToData:masterKey]) {

        _masterKey = masterKey;
        [self.masterKeyTextField setStringValue:[ABDHex hexStringFromByteArray:_masterKey]];
        [_defaults setObject:_masterKey forKey:@"MasterKey"];
        [_defaults synchronize];
    }

    // Save the command APDU.
    commandApdu = [ABDHex byteArrayFromHexString:[self.commandApduTextField stringValue]];
    if (![_commandApdu isEqualToData:commandApdu]) {

        _commandApdu = commandApdu;
        [self.commandApduTextField setStringValue:[ABDHex hexStringFromByteArray:_commandApdu]];
        [_defaults setObject:_commandApdu forKey:@"CommandApdu"];
        [_defaults synchronize];
    }

    // Save the escape command.
    escapeCommand = [ABDHex byteArrayFromHexString:[self.escapeCommandTextField stringValue]];
    if (![_escapeCommand isEqualToData:escapeCommand]) {

        _escapeCommand = escapeCommand;
        [self.escapeCommandTextField setStringValue:[ABDHex hexStringFromByteArray:_escapeCommand]];
        [_defaults setObject:_escapeCommand forKey:@"EscapeCommand"];
        [_defaults synchronize];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)clearData:(id)sender {

    // Clear the device information.
    [self.manufacturerNameTextField setStringValue:@""];
    [self.firmwareRevisionTextField setStringValue:@""];
    [self.modelNumberTextField setStringValue:@""];
    [self.serialNumberTextField setStringValue:@""];
    [self.systemIdTextField setStringValue:@""];
    [self.hardwareRevisionTextField setStringValue:@""];

    // Clear the ATR string.
    [self.atrTextField setStringValue:@""];

    // Clear the card status.
    [self.cardStatusLabel setStringValue:@""];

    // Clear the battery status.
    [self.batteryStatusLabel setStringValue:@""];

    // Clear the battery level.
    [self.batteryLevelLabel setStringValue:@""];

    // Clear the response APDU.
    [self.responseApduTextField setStringValue:@""];

    // Clear the escape response.
    [self.escapeResponseTextField setStringValue:@""];
}

- (IBAction)startScan:(id)sender {

    // Check Bluetooth.
    if ([self ABD_checkBluetooth]) {

        [self.startScanButton setEnabled:NO];

        // Detach the peripheral.
        [_bluetoothReader detach];

        // Disconnect the peripheral.
        if (_peripheral != nil) {

            [_centralManager cancelPeripheralConnection:_peripheral];
            _peripheral = nil;
        }

        // Remove all peripherals.
        [_peripherals removeAllObjects];

        // Reload the table view.
        [_readersTableView reloadData];

        // Scan the peripherals.
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        
        [self.stopScanButton setEnabled:YES];
        [self.connectButton setEnabled:NO];
        [self.disconnectButton setEnabled:NO];
    }
}

- (IBAction)stopScan:(id)sender {

    [self.stopScanButton setEnabled:NO];

    [_centralManager stopScan];

    [self.startScanButton setEnabled:YES];
}

- (IBAction)connect:(id)sender {

    NSInteger row = [self.readersTableView selectedRow];

    [self.connectButton setEnabled:NO];

    // If the peripheral is selected, then stop the scan and connect it.
    if (row >= 0) {

        [self stopScan:self];

        _peripheral = [_peripherals objectAtIndex:row];
        [_centralManager connectPeripheral:_peripheral options:nil];
    }
}

- (IBAction)disconnect:(id)sender {

    [self.disconnectButton setEnabled:NO];

    // Disconnect the peripheral.
    if (_peripheral != nil) {

        [_centralManager cancelPeripheralConnection:_peripheral];
        _peripheral = nil;
    }
}

- (IBAction)authenticate:(id)sender {

    // Authenticate the reader.
    [_bluetoothReader authenticateWithMasterKey:[ABDHex byteArrayFromHexString:[self.masterKeyTextField stringValue]]];
}

- (IBAction)setDefaultMasterKeyForAcr3901us1:(id)sender {
    [self.masterKeyTextField setStringValue:@"FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF"];
}

- (IBAction)setDefaultMasterKeyForAcr1255uj1:(id)sender {
    [self.masterKeyTextField setStringValue:@"41 43 52 31 32 35 35 55 2D 4A 31 20 41 75 74 68"];
}

- (IBAction)getDeviceInfo:(id)sender {

    // Clear the device information.
    [self.manufacturerNameTextField setStringValue:@""];
    [self.firmwareRevisionTextField setStringValue:@""];
    [self.modelNumberTextField setStringValue:@""];
    [self.serialNumberTextField setStringValue:@""];
    [self.systemIdTextField setStringValue:@""];
    [self.hardwareRevisionTextField setStringValue:@""];

    // Get the device information.
    [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoSystemId];
    [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoModelNumberString];
    [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoSerialNumberString];
    [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoFirmwareRevisionString];
    [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoHardwareRevisionString];
    [_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoManufacturerNameString];
}

- (IBAction)getBatteryStatus:(id)sender {

    if ([_bluetoothReader isKindOfClass:[ABTAcr3901us1Reader class]]) {

        ABTAcr3901us1Reader *reader = (ABTAcr3901us1Reader *) _bluetoothReader;

        // Clear the battery status.
        [self.batteryStatusLabel setStringValue:@""];

        // Get the battery status.
        [reader getBatteryStatus];
    }
}

- (IBAction)getBatteryLevel:(id)sender {

    if ([_bluetoothReader isKindOfClass:[ABTAcr1255uj1Reader class]]) {

        ABTAcr1255uj1Reader *reader = (ABTAcr1255uj1Reader *) _bluetoothReader;

        // Clear the battery level.
        [self.batteryLevelLabel setStringValue:@""];

        // Get the battery level.
        [reader getBatteryLevel];
    }
}

- (IBAction)enablePolling:(id)sender {

    if ([_bluetoothReader isKindOfClass:[ABTAcr1255uj1Reader class]]) {

        uint8_t command[] = { 0xE0, 0x00, 0x00, 0x40, 0x01 };

        [_bluetoothReader transmitEscapeCommand:command length:sizeof(command)];
    }
}

- (IBAction)disablePolling:(id)sender {

    if ([_bluetoothReader isKindOfClass:[ABTAcr1255uj1Reader class]]) {

        uint8_t command[] = { 0xE0, 0x00, 0x00, 0x40, 0x00 };

        [_bluetoothReader transmitEscapeCommand:command length:sizeof(command)];
    }
}

- (IBAction)getCardStatus:(id)sender {

    // Clear the card status.
    [self.cardStatusLabel setStringValue:@""];

    // Get the card status.
    [_bluetoothReader getCardStatus];
}

- (IBAction)powerOnCard:(id)sender {

    // Clear the ATR string.
    [self.atrTextField setStringValue:@""];

    // Power on the card.
    [_bluetoothReader powerOnCard];
}

- (IBAction)powerOffCard:(id)sender {
    [_bluetoothReader powerOffCard];
}

- (IBAction)transmitApdu:(id)sender {

    // Clear the response APDU.
    [self.responseApduTextField setStringValue:@""];

    // Transmit the APDU.
    [_bluetoothReader transmitApdu:[ABDHex byteArrayFromHexString:[self.commandApduTextField stringValue]]];
}

- (IBAction)transmitEscapeCommand:(id)sender {

    // Clear the escape response.
    [self.escapeResponseTextField setStringValue:@""];

    // Transmit the escape command.
    [_bluetoothReader transmitEscapeCommand:[ABDHex byteArrayFromHexString:[self.escapeCommandTextField stringValue]]];
}

- (IBAction)setTxPower:(id)sender {

    if ([_bluetoothReader isKindOfClass:[ABTAcr1255uj1Reader class]]) {

        uint8_t command[] = { 0xE0, 0x00, 0x00, 0x49, 0x00 };
        NSInteger txPowerIndex = [self.txPowerPopUpButton indexOfSelectedItem];

        if (txPowerIndex >= 0) {
            command[4] = txPowerIndex;
        }

        [_bluetoothReader transmitEscapeCommand:command length:sizeof(command)];
    }
}

#pragma mark - Central Manager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self ABD_checkBluetooth];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    // If the peripheral is not found, then add it to the array.
    if ([_peripherals indexOfObject:peripheral] == NSNotFound) {

        // Add the peripheral to the array.
        [_peripherals addObject:peripheral];

        // Show the peripheral.
        [_readersTableView reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    // Detect the Bluetooth reader.
    [_bluetoothReaderManager detectReaderWithPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    [self.connectButton setEnabled:YES];

    // Show the error
    if (error != nil) {
        [self ABD_showError:error];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    [self.connectButton setEnabled:YES];
    [self.disconnectButton setEnabled:NO];
    [self.authenticateButton setEnabled:NO];
    [self.getDeviceInfoButton setEnabled:NO];
    [self.powerOnCardButton setEnabled:NO];
    [self.powerOffCardButton setEnabled:NO];
    [self.getCardStatusButton setEnabled:NO];
    [self.getBatteryStatusButton setEnabled:NO];
    [self.getBatteryLevelButton setEnabled:NO];
    [self.enablePollingButton setEnabled:NO];
    [self.disablePollingButton setEnabled:NO];
    [self.transmitApduButton setEnabled:NO];
    [self.transmitEscapeCommandButton setEnabled:NO];
    [self.txPowerPopUpButton setEnabled:NO];

    // Clear the data.
    [self clearData:nil];

    // Show the error
    if (error != nil) {

        [self ABD_showError:error];

    } else {

        NSAlert *alert = [[NSAlert alloc] init];

        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"The reader is disconnected successfully."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
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

    [self.disconnectButton setEnabled:YES];

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        NSAlert *alert = [[NSAlert alloc] init];

        [self.authenticateButton setEnabled:YES];
        [self.getDeviceInfoButton setEnabled:YES];
        [self.powerOnCardButton setEnabled:YES];
        [self.powerOffCardButton setEnabled:YES];
        [self.getCardStatusButton setEnabled:YES];

        if ([_bluetoothReader isKindOfClass:[ABTAcr3901us1Reader class]]) {

            [self.getBatteryStatusButton setEnabled:YES];

        } else if ([_bluetoothReader isKindOfClass:[ABTAcr1255uj1Reader class]]) {

            [self.getBatteryLevelButton setEnabled:YES];
            [self.enablePollingButton setEnabled:YES];
            [self.disablePollingButton setEnabled:YES];
            [self.txPowerPopUpButton setEnabled:YES];
        }

        [self.transmitApduButton setEnabled:YES];
        [self.transmitEscapeCommandButton setEnabled:YES];

        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"The reader is attached to the peripheral successfully."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnDeviceInfo:(NSObject *)deviceInfo type:(ABTBluetoothReaderDeviceInfo)type error:(NSError *)error {

    // Show the error
    if (error != nil) {

        [self ABD_showError:error];

    } else {

        switch (type) {

            case ABTBluetoothReaderDeviceInfoSystemId:
                // Show the system ID.
                [self.systemIdTextField setStringValue:[ABDHex hexStringFromByteArray:(NSData *)deviceInfo]];
                break;

            case ABTBluetoothReaderDeviceInfoModelNumberString:
                // Show the model number.
                [self.modelNumberTextField setStringValue:(NSString *)deviceInfo];
                break;

            case ABTBluetoothReaderDeviceInfoSerialNumberString:
                // Show the serial number.
                [self.serialNumberTextField setStringValue:(NSString *)deviceInfo];
                break;

            case ABTBluetoothReaderDeviceInfoFirmwareRevisionString:
                // Show the firmware revision.
                [self.firmwareRevisionTextField setStringValue:(NSString *)deviceInfo];
                break;

            case ABTBluetoothReaderDeviceInfoHardwareRevisionString:
                // Show the hardware revision.
                [self.hardwareRevisionTextField setStringValue:(NSString *)deviceInfo];
                break;

            case ABTBluetoothReaderDeviceInfoManufacturerNameString:
                // Show the manufacturer name.
                [self.manufacturerNameTextField setStringValue:(NSString *)deviceInfo];
                break;
                
            default:
                break;
        }
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didAuthenticateWithError:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        NSAlert *alert = [[NSAlert alloc] init];

        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"The reader is authenticated successfully."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnAtr:(NSData *)atr error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the ATR string.
        [self.atrTextField setStringValue:[ABDHex hexStringFromByteArray:atr]];
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
        [self.cardStatusLabel setStringValue:[self ABD_stringFromCardStatus:cardStatus]];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnResponseApdu:(NSData *)apdu error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the response APDU.
        [self.responseApduTextField setStringValue:[ABDHex hexStringFromByteArray:apdu]];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnEscapeResponse:(NSData *)response error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the escape response.
        [self.escapeResponseTextField setStringValue:[ABDHex hexStringFromByteArray:response]];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeCardStatus:(ABTBluetoothReaderCardStatus)cardStatus error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the card status.
        [self.cardStatusLabel setStringValue:[self ABD_stringFromCardStatus:cardStatus]];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeBatteryStatus:(ABTBluetoothReaderBatteryStatus)batteryStatus error:(NSError *)error {
    
    if (error != nil) {
        
        // Show the error
        [self ABD_showError:error];
        
    } else {
        
        // Show the battery status.
        [self.batteryStatusLabel setStringValue:[self ABD_stringFromBatteryStatus:batteryStatus]];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeBatteryLevel:(NSUInteger)batteryLevel error:(NSError *)error {

    if (error != nil) {

        // Show the error
        [self ABD_showError:error];

    } else {

        // Show the battery level.
        [self.batteryLevelLabel setStringValue:[NSString stringWithFormat:@"%lu%%", (unsigned long) batteryLevel]];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_peripherals count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    NSString *readerName = nil;
    CBPeripheral *peripheral = [_peripherals objectAtIndex:row];

    if (peripheral.name == nil) {
        readerName = @"Unknown";
    } else {
        readerName = peripheral.name;
    }

    return readerName;
}

#pragma mark - Table View

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self.connectButton setEnabled:YES];
}

#pragma mark - Private Methods

/**
 * Returns YES if Bluetooth is ready.
 */
- (BOOL)ABD_checkBluetooth {

    NSString *message = nil;

    switch (_centralManager.state) {

        case CBCentralManagerStateUnsupported:
            message = @"This device does not support Bluetooth low energy.";
            break;

        case CBCentralManagerStateUnauthorized:
            message = @"This app is not authorized to use Bluetooth low energy.";
            break;

        case CBCentralManagerStatePoweredOff:
            message = @"You must turn on Bluetooth in order to use the reader.";
            break;

        case CBCentralManagerStatePoweredOn:
            break;

        default:
            message = @"The update is being started. Please wait until Bluetooth is ready.";
            break;
    }

    if (message != nil) {

        NSAlert *alert = [[NSAlert alloc] init];

        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:message];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }

    return (message == nil);
}

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

    NSAlert *alert = [[NSAlert alloc] init];

    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:[NSString stringWithFormat:@"Error %ld", (long)[error code]]];
    [alert setInformativeText:[error localizedDescription]];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert runModal];
}

@end
