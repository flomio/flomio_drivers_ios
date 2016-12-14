//
//  FlomioBtReader.h
//  SDK
//
//  Created by Richard Grundy on 11/28/16.
//  Copyright (c) 2014 Flomio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol FloBLEReaderDelegate <NSObject>
@optional
- (void)handleReceivedByte:(UInt8)byte withParity:(BOOL)parityGood atTimestamp:(double)timestamp;
- (void)updateLog:(NSString*)logText;
- (void)didReceiveServiceFirmwareVersion:(NSString *)theVersionNumber;
- (void)didReceivedImageBlockTransferCharacteristic:(NSData*)imageBlockCharacteristic;
- (void)didReceivedImageIdentifyCharacteristic:(NSData*)imageBlockCharacteristic;

@end

@interface FlomioBtReader : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager * myCentralManager;
    CBPeripheral *activePeripheral;
    CBCharacteristic * batteryLevelCharacteristic;
    CBCharacteristic * serialF2hPortBlockCharacteristic;
    CBCharacteristic * serialH2fPortBlockCharacteristic;
    NSMutableArray * rfUid;
    NSTimer * bleTimer;
}

@property (strong, nonatomic) CBCentralManager * myCentralManager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (strong, nonatomic) CBCharacteristic * batteryLevelCharacteristic;
@property (strong, nonatomic) CBCharacteristic * serialF2hPortBlockCharacteristic;
@property (strong, nonatomic) CBCharacteristic * serialH2fPortBlockCharacteristic;

@property (copy, nonatomic) NSMutableArray * rfUid;
@property (retain, nonatomic) NSTimer * bleTimer;
@property id<FloBLEReaderDelegate> delegate;

- (id)init;
- (void)startScan;
- (void)disconnectPeripheral:(CBPeripheral*)peripheral;
- (void) startScanningForUUIDString:(NSString *)uuidString;
- (void) startScanningForCBUUID:(CBUUID *)uuid;
- (void) startScanningForCBUUIDs:(NSArray *)uuidArray;
- (void) discoverServicesForUUIDString:(CBPeripheral *)peripheral uuidString:(NSString *)uuidString;
- (void) discoverServicesForCBUUID:(CBPeripheral *)peripheral cbuuid:(CBUUID *)uuid;
- (void) discoverServicesForCBUUID:(CBPeripheral *)peripheral withCBUUIDs:(NSArray *)uuidArray;
- (void)delayStartScanTimerService:(NSTimer*)aTimer;
- (id)initWithDelegate:(id<FloBLEReaderDelegate>)floBleDelegate;
- (void)writePeriperalWithResponse:(UInt8*)dataToWrite;
- (void)writePeriperalWithOutResponse:(UInt8*)dataToWrite;
- (void)writeBlockToPeriperalWithOutResponse:(UInt8*)dataToWrite ofLength:(UInt8)len;

+ (CBUUID *) deviceInformationServiceUuid16bit;
+ (CBUUID *) batteryServiceUuid16bit;
+ (CBUUID *) batteryLevelCharacteristicUuid128bit;
+ (CBUUID *) floBleServiceUuid16bit;
+ (CBUUID *) floBleServiceUuid128bit;
+ (CBUUID *) f2hBlockCharacteristicUuid128bit;
+ (CBUUID *) h2fBlockCharacteristicUuid128bit;

@end
