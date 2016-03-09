/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <ACSBluetooth/ABTBluetoothReaderManager.h>
#import <ACSBluetooth/ABTBluetoothReader.h>
#import <ACSBluetooth/ABTAcr3901us1Reader.h>
#import <ACSBluetooth/ABTAcr1255uj1Reader.h>
#import <ACSBluetooth/ABTError.h>

/**
@mainpage

@section intro Introduction

This library provides classes and protocols for communicating with ACS Bluetooth
readers on iOS (5.0 or above) and Mac OS X (10.7 or above).

To use the library on iOS, your app must include <code>CoreBluetooth</code>
header file from iOS SDK and <code>ACSBluetooth</code> header file.

@code
//
//  MYViewController.m
//

#import "MYViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <ACSBluetooth/ACSBluetooth.h>

@interface MYViewController () <CBCentralManagerDelegate, ABTBluetoothReaderManagerDelegate, ABTBluetoothReaderDelegate>

@end

@implementation MYViewController {

    CBCentralManager *_centralManager;
    CBPeripheral *_peripheral;
    ABTBluetoothReaderManager *_bluetoothReaderManager;
    ABTBluetoothReader *_bluetoothReader;

    ...
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    ...

    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _bluetoothReaderManager = [[ABTBluetoothReaderManager alloc] init];
    _bluetoothReaderManager.delegate = self;

    ...
}

...
@endcode

To use the library on Mac OS X, your app must include <code>IOBluetooth</code>
header file from Mac OS X SDK and <code>ACSBluetooth</code> header file.

@code
//
// MYAppDelegate.m
//

#import "MYAppDelegate.h"
#import <IOBluetooth/IOBluetooth.h>
#import <ACSBluetooth/ACSBluetooth.h>

@interface ABDAppDelegate () <CBCentralManagerDelegate, ABTBluetoothReaderManagerDelegate, ABTBluetoothReaderDelegate>

@end

@implementation ABDAppDelegate {

    CBCentralManager *_centralManager;
    CBPeripheral *_peripheral;
    ABTBluetoothReaderManager *_bluetoothReaderManager;
    ABTBluetoothReader *_bluetoothReader;

    ...
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _bluetoothReaderManager = [[ABTBluetoothReaderManager alloc] init];
    _bluetoothReaderManager.delegate = self;

    ...
}

...
@endcode

Your app must create <code>CBCentralManager</code> and ABTBluetoothReaderManager
objects and then assign a delegate object to them. Therefore, your delegate
object will receive the events from central manager and Bluetooth reader
manager.

You must implement <code>centralManagerDidUpdateState:</code> method to check if
Bluetooth low energy is supported and available to use.

@code
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

    // TODO: Check if Bluetooth low energy is supported and available to use.
    ...
}
@endcode

@section peripherals Discovering peripherals

You can discover peripherals by calling
<code>scanForPeripheralsWithServices:options:</code> method of the
<code>CBCentralManager</code> class.

@code
[_centralManager scanForPeripheralsWithServices:nil options:nil];
@endcode

When the peripheral is discovered, the central manager calls
<code>centralManager:didDiscoverPeripheral:advertisementData:RSSI:</code> method
of its delegate object. You need to store the returned <code>CBPeripheral</code>
object.

@code
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    // Store the peripheral.
    _peripheral = peripheral;
}
@endcode

When you have found the peripheral, you can stop the scanning for other devices
to save the power.

@code
[_centralManager stopScan];
@endcode

@section connect Connecting to the peripheral

After finding the peripheral, you can connect it by calling
<code>connectPeripheral:options:</code> method of the
<code>CBCentralManager</code> class.

@code
[_centralManager connectPeripheral:_peripheral options:nil];
@endcode

If the connection is successful, the central manager will call
<code>centralManager:didConnectPeripheral:</code> method of its delegate object.
Otherwise, it will call <code>centralManager:didFailToConnectPeripheral:</code>
method of its delegate object.

@code
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    // Detect the Bluetooth reader.
    [_bluetoothReaderManager detectReaderWithPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    // TODO: Show the connection error.
    // ...
}
@endcode

@section detect Detecting the Bluetooth reader

After the peripheral is connected, you can detect the Bluetooth reader by
calling ABTBluetoothReaderManager::detectReaderWithPeripheral: method of the
ABTBluetoothReaderManager class. The Bluetooth reader manager calls
ABTBluetoothReaderManagerDelegate::bluetoothReaderManager:didDetectReader:peripheral:error:
method of its delegate object to return the result.

@code
- (void)bluetoothReaderManager:(ABTBluetoothReaderManager *)bluetoothReaderManager didDetectReader:(ABTBluetoothReader *)reader peripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    if (error != nil) {

        // TODO: Show the error.
        // ...

    } else {

        // Store the Bluetooth reader.
        _bluetoothReader = reader;
        _bluetoothReader.delegate = self;

        // Attach the peripheral to the Bluetooth reader.
        [_bluetoothReader attachPeripheral:peripheral];
    }
}
@endcode

@section attach Attaching the peripheral

You can attach the peripheral by calling ABTBluetoothReader::attachPeripheral:
method of the ABTBluetoothReader class. The Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didAttachPeripheral:error: method of
its delegate object to return the result.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didAttachPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    // TODO: Show the error.
    // ...
}
@endcode

@section detach Detaching the peripheral

If you have finished the operation with the Bluetooth reader, you can detach the
peripheral by calling ABTBluetoothReader::detach method of the
ABTBluetoothReader class.

@code
[_bluetoothReader detach];
@endcode

@section disconnect Disconnecting the peripheral

If your Bluetooth reader is no longer used, you can disconnect the peripheral
by calling <code>cancelPeripheralConnection:</code> method of the
<code>CBCentralManager</code> class.

@code
[_centralManager cancelPeripheralConnection:_peripheral];
@endcode

The central manager calls
<code>centralManager:didDisconnectPeripheral:error:</code> of its delegate
object.

@code
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    // TODO: Show the error.
    // ...
}
@endcode

@section deviceinfo Getting the device information

You can get the device information by calling
ABTBluetoothReader::getDeviceInfoWithType: method of ABTBluetoothReader class.
If the device information is not supported, the method will returns
<code>NO</code>.

@code
[_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoSystemId];
[_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoModelNumberString];
[_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoSerialNumberString];
[_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoFirmwareRevisionString];
[_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoHardwareRevisionString];
[_bluetoothReader getDeviceInfoWithType:ABTBluetoothReaderDeviceInfoManufacturerNameString];
@endcode

The Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didReturnDeviceInfo:type:error:
method of its delegate object to return the device information.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnDeviceInfo:(NSObject *)deviceInfo type:(ABTBluetoothReaderDeviceInfo)type error:(NSError *)error {

    if (error != nil) {

        // TODO: Show the error.
        // ...

    } else {

        switch (type) {

            case ABTBluetoothReaderDeviceInfoSystemId:
                // TODO: Show the system ID.
                // ...
                break;

            case ABTBluetoothReaderDeviceInfoModelNumberString:
                // TODO: Show the model number.
                // ...
                break;

            case ABTBluetoothReaderDeviceInfoSerialNumberString:
                // TODO: Show the serial number.
                // ...
                break;

            case ABTBluetoothReaderDeviceInfoFirmwareRevisionString:
                // TODO: Show the firmware revision.
                // ...
                break;

            case ABTBluetoothReaderDeviceInfoHardwareRevisionString:
                // TODO: Show the hardware revision.
                // ...
                break;

            case ABTBluetoothReaderDeviceInfoManufacturerNameString:
                // TODO: Show the manufacturer name.
                // ...
                break;

            default:
                break;
        }
    }
}
@endcode

@section acr3901us1 Working with ACR3901U-S1 reader

If the ACR3901U-S1 reader is detected, the returned ABTBluetoothReader object
will be an instance of ABTAcr3901us1Reader class. To invoke the method, you can
cast it as ABTAcr3901us1Reader object.

@code
if ([_bluetoothReader isKindOfClass:[ABTAcr3901us1Reader class]]) {

    ABTAcr3901us1Reader *reader = (ABTAcr3901us1Reader *) _bluetoothReader;

    // TODO: Invoke the method.
    // ...
}
@endcode

@subsection batterystatus Getting the battery status

If the battery status is changed, the Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didChangeBatteryStatus:error: method
of its delegate object to return the battery status.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeBatteryStatus:(ABTBluetoothReaderBatteryStatus)batteryStatus error:(NSError *)error {

    // TODO: Process the battery status.
    // ...
}
@endcode

If you want to get the battery status again, you can call
ABTAcr3901us1Reader::getBatteryStatus method of ABTAcr3901us1Reader class.

@code
[reader getBatteryStatus];
@endcode

@section acr1255uj1 Working with ACR1255U-J1 reader

If the ACR1255U-J1 reader is detected, the returned ABTBluetoothReader object
will be an instance of ABTAcr1255uj1Reader class. To invoke the method, you can
cast it as ABTAcr1255uj1Reader object.

@code
if ([_bluetoothReader isKindOfClass:[ABTAcr1255uj1Reader class]]) {

    ABTAcr1255uj1Reader *reader = (ABTAcr1255uj1Reader *) _bluetoothReader;

    // TODO: Invoke the method.
    // ...
}
@endcode

@subsection batterylevel Getting the battery level

If the battery level is changed, the Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didChangeBatteryLevel:error: method
of its delegate object to return the battery level.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeBatteryLevel:(NSUInteger)batteryLevel error:(NSError *)error {

    // TODO: Process the battery level.
    // ...
}
@endcode

If you want to get the battery level again, you can call
ABTAcr1255uj1Reader::getBatteryLevel method of ABTAcr1255uj1Reader class.

@code
[reader getBatteryLevel];
@endcode

@section authenticate Authenticating the Bluetooth reader

Before performing the operation, you must authenticate the Bluetooth reader by
calling ABTBluetoothReader::authenticateWithMasterKey: method of
ABTBluetoothReader class with the master key.

@code
[reader authenticateWithMasterKey:_masterKey];
@endcode

The Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didAuthenticateWithError: method
of its delegate object to return the authentication result.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didAuthenticateWithError:(NSError *)error {

    // TODO: Show the error.
    // ...
}
@endcode

@section poweron Powering on the card

If the Bluetooth reader is authenticated successfully, you can power on the card
by calling ABTBluetoothReader::powerOnCard method of ABTBluetoothReader class.

@code
[_bluetoothReader powerOnCard];
@endcode

The Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didReturnAtr:error: method of its
delegate object to return the ATR string.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnAtr:(NSData *)atr error:(NSError *)error {

    // TODO: Process the ATR string from the card.
    // ...
}
@endcode

@section poweroff Powering off the card

If the Bluetooth reader is authenticated successfully, you can power off the
card by calling ABTBluetoothReader::powerOffCard method of ABTBluetoothReader
class.

@code
[_bluetoothReader powerOffCard];
@endcode

The Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didPowerOffCardWithError: method of
its delegate object to notify the result.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didPowerOffCardWithError:(NSError *)error {

    // TODO: Show the error.
    // ...
}
@endcode

@section cardstatus Getting the card status

If the Bluetooth reader is authenticated successfully, you can get the card
status by calling ABTBluetoothReader::getCardStatus method of ABTBluetoothReader
class.

@code
[_bluetoothReader getCardStatus];
@endcode


The Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didReturnCardStatus:error: method of
its delegate object to return the card status.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnCardStatus:(ABTBluetoothReaderCardStatus)cardStatus error:(NSError *)error {

    // TODO: Process the card status.
    // ...
}
@endcode

If the card status is changed, the Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didChangeCardStatus:error: method of
its delegate object to return the card status.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeCardStatus:(ABTBluetoothReaderCardStatus)cardStatus error:(NSError *)error {

    // TODO: Process the card status.
    // ...
}
@endcode

@section apdu Transmitting the APDU

If the Bluetooth reader is authenticated successfully, you can transmit the APDU
to the card by calling ABTBluetoothReader::transmitApdu: method of
ABTBluetoothReader class.

@code
[_bluetoothReader transmitApdu:_commandApdu];
@endcode

The Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didReturnResponseApdu:error: method
of its delegate object to return the response APDU.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnResponseApdu:(NSData *)apdu error:(NSError *)error {

    // TODO: Process the response APDU.
    // ...
}
@endcode

@section escape Transmitting the escape command

If the Bluetooth reader is authenticated successfully, you can transmit the
escape command by calling ABTBluetoothReader::transmitEscapeCommand: method of
ABTBluetoothReader class.

@code
[_bluetoothReader transmitEscapeCommand:_escapeCommand];
@endcode

The Bluetooth reader calls
ABTBluetoothReaderDelegate::bluetoothReader:didReturnEscapeResponse:error:
method of its delegate object to return the escape response.

@code
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnEscapeResponse:(NSData *)response error:(NSError *)error {

    // TODO: Process the escape response.
    // ...
}
@endcode
*/
