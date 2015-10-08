/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <Foundation/Foundation.h>

/** Card status. */
enum {

    /** The card status is unknown. */
    ABTBluetoothReaderCardStatusUnknown = 0,

    /** No card is present. */
    ABTBluetoothReaderCardStatusAbsent = 1,

    /** The card is present and inactive. */
    ABTBluetoothReaderCardStatusPresent = 2,

    /** The card is present and active. */
    ABTBluetoothReaderCardStatusPowered = 3,

    /** The reader is in power saving mode. */
    ABTBluetoothReaderCardStatusPowerSavingMode = 0xFF
};

/** Card status type. */
typedef NSUInteger ABTBluetoothReaderCardStatus;

/** Battery status. */
enum {

    /** No battery. */
    ABTBluetoothReaderBatteryStatusNone = 0,

    /** The battery is full. */
    ABTBluetoothReaderBatteryStatusFull = 0xFE,

    /** The USB is plugged. */
    ABTBluetoothReaderBatteryStatusUsbPlugged = 0xFF
};

/** Battery status type. */
typedef NSUInteger ABTBluetoothReaderBatteryStatus;

/** Device information type. */
enum {

    /** System ID. */
    ABTBluetoothReaderDeviceInfoSystemId = 0x2A23,

    /** Model number string. */
    ABTBluetoothReaderDeviceInfoModelNumberString = 0x2A24,

    /** Serial number string. */
    ABTBluetoothReaderDeviceInfoSerialNumberString = 0x2A25,

    /** Firmware revision string. */
    ABTBluetoothReaderDeviceInfoFirmwareRevisionString = 0x2A26,

    /** Hardware revision string. */
    ABTBluetoothReaderDeviceInfoHardwareRevisionString = 0x2A27,

    /** Manufacturer name string. */
    ABTBluetoothReaderDeviceInfoManufacturerNameString = 0x2A29
};

/** Device information type. */
typedef NSUInteger ABTBluetoothReaderDeviceInfo;

@class CBPeripheral;
@protocol ABTBluetoothReaderDelegate;

/**
 * The <code>ABTBluetoothReader</code> class represents ACS Bluetooth readers.
 * @author  Godfrey Chung
 * @version 1.0, 5 May 2014
 */
@interface ABTBluetoothReader : NSObject {

@protected
    BOOL _attached;
    CBPeripheral *_peripheral;
}

/** The delegate object specified to receive the Bluetooth reader events. */
@property (nonatomic, weak) id<ABTBluetoothReaderDelegate> delegate;

/**
 * Attaches the reader to the peripheral.
 * @param peripheral the peripheral.
 */
- (void)attachPeripheral:(CBPeripheral *)peripheral;

/** Detaches the peripheral. */
- (void)detach;

/**
 * Gets the device information. When the Bluetooth reader returns the device
 * information, it calls the
 * ABTBluetoothReaderDelegate::bluetoothReader:didReturnDeviceInfo:type:error:
 * method of its delegate object.
 * @param type the device information type.
 * @return <code>YES</code> if the reader is attached and the device information
 *         type is supported, otherwise <code>NO</code>.
 */
- (BOOL)getDeviceInfoWithType:(ABTBluetoothReaderDeviceInfo)type;

/**
 * Authenticates the reader.
 * @param masterKey the master key. The length must be 16 bytes.
 * @return <code>YES</code> if the reader is attached, otherwise
 *         <code>NO</code>.
 */
- (BOOL)authenticateWithMasterKey:(NSData *)masterKey;

/**
 * Authenticates the reader.
 * @param masterKey the master key.
 * @param length    the master key length. The length must be 16 bytes.
 * @return <code>YES</code> if the reader is attached, otherwise
 *         <code>NO</code>.
 */
- (BOOL)authenticateWithMasterKey:(const uint8_t *)masterKey length:(NSUInteger)length;

/**
 * Powers on the card. In order to proceed this operation, your reader must be
 * authenticated. When the Bluetooth reader powers on the card, it calls the
 * ABTBluetoothReaderDelegate::bluetoothReader:didReturnAtr:error: method of its
 * delegate object.
 * @return <code>YES</code> if the reader is attached, otherwise
 *         <code>NO</code>.
 * @see ABTBluetoothReader::authenticateWithMasterKey:
 * @see ABTBluetoothReader::authenticateWithMasterKey:length:
 */
- (BOOL)powerOnCard;

/**
 * Powers off the card. In order to proceed this operation, your reader must be
 * authenticated. When the Bluetooth reader powers off the card, it calls the
 * ABTBluetoothReaderDelegate::bluetoothReader:didPowerOffCardWithError: method
 * of its delegate object.
 * @return <code>YES</code> if the reader is attached, otherwise
 *         <code>NO</code>.
 * @see ABTBluetoothReader::authenticateWithMasterKey:
 * @see ABTBluetoothReader::authenticateWithMasterKey:length:
 */
- (BOOL)powerOffCard;

/**
 * Gets the card status. In order to proceed this operation, your reader must be
 * authenticated. When the Bluetooth reader returns the card status, it calls
 * the ABTBluetoothReaderDelegate::bluetoothReader:didReturnCardStatus:error:
 * method of its delegate object.
 * @return <code>YES</code> if the reader is attached, otherwise
 *         <code>NO</code>.
 * @see ABTBluetoothReader::authenticateWithMasterKey:
 * @see ABTBluetoothReader::authenticateWithMasterKey:length:
 */
- (BOOL)getCardStatus;

/**
 * Transmits the APDU. In order to proceed this operation, your reader must be
 * authenticated. When the Bluetooth reader returns the response APDU, it calls
 * the ABTBluetoothReaderDelegate::bluetoothReader:didReturnResponseApdu:error:
 * method of its delegate object.
 * @param apdu the command APDU.
 * @return <code>YES</code> if the reader is attached, otherwise
 *         <code>NO</code>.
 * @see ABTBluetoothReader::authenticateWithMasterKey:
 * @see ABTBluetoothReader::authenticateWithMasterKey:length:
 */
- (BOOL)transmitApdu:(NSData *)apdu;

/**
 * Transmits the APDU. In order to proceed this operation, your reader must be
 * authenticated. When the Bluetooth reader returns the response APDU, it calls
 * the ABTBluetoothReaderDelegate::bluetoothReader:didReturnResponseApdu:error:
 * method of its delegate object.
 * @param apdu   the command APDU.
 * @param length the command APDU length.
 * @return <code>YES</code> if the reader is attached, otherwise
 *         <code>NO</code>.
 * @see ABTBluetoothReader::authenticateWithMasterKey:
 * @see ABTBluetoothReader::authenticateWithMasterKey:length:
 */
- (BOOL)transmitApdu:(const uint8_t *)apdu length:(NSUInteger)length;

/**
 * Transmits the escape command. When the Bluetooth reader returns the escape
 * response, it calls the
 * ABTBluetoothReaderDelegate::bluetoothReader:didReturnEscapeResponse:error:
 * method of its delegate object.
 * @param command the escape command.
 * @return <code>YES</code> if the reader is attached, otherwise
 *         <code>NO</code>.
 */
- (BOOL)transmitEscapeCommand:(NSData *)command;

/**
 * Transmits the escape command. When the Bluetooth reader returns the escape
 * response, it calls the
 * ABTBluetoothReaderDelegate::bluetoothReader:didReturnEscapeResponse:error:
 * method of its delegate object.
 * @param command the escape command.
 * @param length  the escape command length.
 * @return <code>YES</code> if the reader is attached, otherwise
 *         <code>NO</code>.
 */
- (BOOL)transmitEscapeCommand:(const uint8_t *)command length:(NSUInteger)length;

@end

/**
 * The <code>ABTBluetoothReaderDelegate</code> protocol defines the response
 * sent to a delegate of <code>ABTBluetoothReader</code> object.
 */
@protocol ABTBluetoothReaderDelegate <NSObject>
@optional

/**
 * Invoked when the Bluetooth reader attaches to the peripheral.
 * @param bluetoothReader the Bluetooth reader.
 * @param peripheral      the peripheral.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didAttachPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

/**
 * Invoked when the Bluetooth reader returns the device information.
 * @param bluetoothReader the Bluetooth reader.
 * @param deviceInfo      the device information.
 * @param type            the device information type.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnDeviceInfo:(NSObject *)deviceInfo type:(ABTBluetoothReaderDeviceInfo)type error:(NSError *)error;

/**
 * Invoked when the Bluetooth reader changes the card status.
 * @param bluetoothReader the Bluetooth reader.
 * @param cardStatus      the card status.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeCardStatus:(ABTBluetoothReaderCardStatus)cardStatus error:(NSError *)error;

/**
 * Invoked when the Bluetooth reader changes the battery status.
 * @param bluetoothReader the Bluetooth reader.
 * @param batteryStatus   the battery status.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeBatteryStatus:(ABTBluetoothReaderBatteryStatus)batteryStatus error:(NSError *)error;

/**
 * Invoked when the Bluetooth reader changes the battery level.
 * @param bluetoothReader the Bluetooth reader.
 * @param batteryLevel    the battery level in percentage.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeBatteryLevel:(NSUInteger)batteryLevel error:(NSError *)error;

/**
 * Invoked when the Bluetooth reader is authenticated.
 * @param bluetoothReader the Bluetooth reader.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didAuthenticateWithError:(NSError *)error;

/**
 * Invoked when the Bluetooth reader returns the ATR string after powering on
 * the card.
 * @param bluetoothReader the Bluetooth reader.
 * @param atr             the ATR string.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnAtr:(NSData *)atr error:(NSError *)error;

/**
 * Invoked when the Bluetooth reader powers off the card.
 * @param bluetoothReader the Bluetooth reader.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didPowerOffCardWithError:(NSError *)error;

/**
 * Invoked when the Bluetooth reader returns the card status.
 * @param bluetoothReader the Bluetooth reader.
 * @param cardStatus      the card status.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnCardStatus:(ABTBluetoothReaderCardStatus)cardStatus error:(NSError *)error;

/**
 * Invoked when the Bluetooth reader returns the response APDU.
 * @param bluetoothReader the Bluetooth reader.
 * @param apdu            the response APDU.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnResponseApdu:(NSData *)apdu error:(NSError *)error;

/**
 * Invoked when the Bluetooth reader returns the escape response.
 * @param bluetoothReader the Bluetooth reader.
 * @param response        the escape response.
 * @param error           the error.
 */
- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnEscapeResponse:(NSData *)response error:(NSError *)error;

@end
