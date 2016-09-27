//
//  FloBLEReader.h
//  Badanamu
//
//  Created by Chuck Carter on 10/13/14.
//  Copyright (c) 2014 Flomio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FLOReader.h"
#import "FloNotifications.h"
#import "FloProtocolsCommon.h"

extern NSString * const floReaderConnectionStatusChangeNotification;

@protocol FloBLEReaderDelegate <NSObject,FLOReaderDelegate>
//- (void) didReceiveData:(NSString *) string;
@optional
- (void)handleReceivedByte:(UInt8)byte withParity:(BOOL)parityGood atTimestamp:(double)timestamp;
- (void)updateLog:(NSString*)logText;
- (void)didReceiveServiceFirmwareVersion:(NSString *)theVersionNumber;
//- (void)didReadHardwareRevisionString:(NSString *) string;
- (void)didReceivedImageBlockTransferCharacteristic:(NSData*)imageBlockCharacteristic;
- (void)didReceivedImageIdentifyCharacteristic:(NSData*)imageBlockCharacteristic;

@end

@interface FloBLEReader : FLOReader <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager * myCentralManager;
    CBPeripheral *activePeripheral;
    CBCharacteristic * serialF2hPortBlockCharacteristic;
    CBCharacteristic * serialH2fPortBlockCharacteristic;
    CBCharacteristic * oadServiceCharacteristic;
    CBCharacteristic * oadImageIdentifyCharacteristic;
    CBCharacteristic * oadImageBlockTransferCharacteristic;
    CBCharacteristic * firmwareRevisionStringCharacteristic;
    CBCharacteristic * arcBootServiceCharacteristic;
    NSMutableArray * rfUid;
    NSTimer * bleTimer;
    deviceState_t deviceState;
}

@property (assign) deviceState_t deviceState;
@property (assign) BOOL isConnected;
@property (strong, nonatomic) CBCentralManager * myCentralManager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (strong, nonatomic) CBCharacteristic * serialF2hPortBlockCharacteristic;
@property (strong, nonatomic) CBCharacteristic * serialH2fPortBlockCharacteristic;
@property (strong, nonatomic) CBCharacteristic * oadServiceCharacteristic;
@property (strong, nonatomic) CBCharacteristic * oadImageIdentifyCharacteristic;
@property (strong, nonatomic) CBCharacteristic * oadImageBlockTransferCharacteristic;
@property (strong, nonatomic) CBCharacteristic * firmwareRevisionStringCharacteristic;
@property (strong, nonatomic) CBCharacteristic * arcBootServiceCharacteristic;

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
- (void)writeBlockToOadImageIdentifyWithOutResponse:(UInt8*)dataToWrite ofLength:(UInt8)len;
- (void)writeBlockToOadImageBlockTransferWithOutResponse:(UInt8*)dataToWrite ofLength:(UInt8)len;
- (protocolType_t)protocolType;

+ (CBUUID *) deviceInformationServiceUuid16bit;
+ (CBUUID *) oadServiceUuid16bit;
+ (CBUUID *) oadServiceUuid128bit;
+ (CBUUID *) floBleServiceUuid16bit;
+ (CBUUID *) floBleServiceUuid128bit;
+ (CBUUID *) f2hBlockCharacteristicUuid128bit;
+ (CBUUID *) h2fBlockCharacteristicUuid128bit;
+ (CBUUID *) oadImageIdentifyCharacteristicUuid128bit;
+ (CBUUID *) oadImageBlockTransferCharacteristicUuid128bit;

@end
