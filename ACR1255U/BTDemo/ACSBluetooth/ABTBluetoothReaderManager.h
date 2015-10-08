/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <Foundation/Foundation.h>

@class CBPeripheral;
@class ABTBluetoothReader;
@protocol ABTBluetoothReaderManagerDelegate;

/**
 * The <code>ABTBluetoothReaderManager</code> class detects ACS Bluetooth
 * readers.
 * @author  Godfrey Chung
 * @version 1.0, 25 Jul 2014
 */
@interface ABTBluetoothReaderManager : NSObject

/**
 * The delegate object specified to receive the Bluetooth reader manager events.
 */
@property (nonatomic, weak) id<ABTBluetoothReaderManagerDelegate> delegate;

/**
 * Detects the reader with the peripheral. When the Bluetooth reader manager
 * detect the reader, it calls the
 * ABTBluetoothReaderManagerDelegate::bluetoothReaderManager:didDetectReader:peripheral:error:
 * method of its delegate object.
 * @param peripheral the peripheral.
 */
- (void)detectReaderWithPeripheral:(CBPeripheral *)peripheral;

@end

/**
 * The <code>ABTBluetoothReaderManagerDelegate</code> protocol defines the
 * response sent to a delegate of <code>ABTBluetoothReaderManager</code> object.
 */
@protocol ABTBluetoothReaderManagerDelegate <NSObject>
@optional

/**
 * Invoked when the Bluetooth reader is detected.
 * @param bluetoothReaderManager the Bluetooth reader manager.
 * @param reader                 the Bluetooth reader.
 * @param peripheral             the peripheral.
 * @param error                  the error.
 */
- (void)bluetoothReaderManager:(ABTBluetoothReaderManager *)bluetoothReaderManager didDetectReader:(ABTBluetoothReader *)reader peripheral:(CBPeripheral *)peripheral error:(NSError *)error;

@end
