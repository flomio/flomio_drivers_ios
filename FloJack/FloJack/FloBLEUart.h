//
//  FloBLEUart.h
//  Badanamu
//
//  Created by Chuck Carter on 10/13/14.
//  Copyright (c) 2014 Flomio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FJNFCService.h"
#import "FloBLEUart.h"
#import "FloNotifications.h"
#import "FloProtocolsCommon.h"

extern NSString * const floBLEConnectionStatusChangeNotification;

@protocol FloBLEUartDelegate <NSObject,FJNFCServiceDelegate>
//- (void) didReceiveData:(NSString *) string;
@optional
- (void)handleReceivedByte:(UInt8)byte withParity:(BOOL)parityGood atTimestamp:(double)timestamp;
- (void)updateLog:(NSString*)logText;
//- (void) didReadHardwareRevisionString:(NSString *) string;
@end

@interface FloBLEUart : FJNFCService <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager * myCentralManager;
    CBPeripheral *activePeripheral;
    CBCharacteristic * serialF2hPortCharacteristic;
    CBCharacteristic * serialPortH2fCharacteristic;
    CBCharacteristic * serialF2hPortBlockCharacteristic;
    CBCharacteristic * serialH2fPortBlockCharacteristic;
    NSMutableArray * rfUid;
    NSTimer * bleTimer;
    deviceState_t deviceState;
}

@property (assign) deviceState_t deviceState;
@property (assign) BOOL isConnected;
@property (strong, nonatomic) CBCentralManager * myCentralManager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (strong, nonatomic) CBCharacteristic * serialPortF2hCharacteristic;
@property (strong, nonatomic) CBCharacteristic * serialPortH2fCharacteristic;
@property (strong, nonatomic) CBCharacteristic * serialF2hPortBlockCharacteristic;
@property (strong, nonatomic) CBCharacteristic * serialH2fPortBlockCharacteristic;
@property (copy, nonatomic) NSMutableArray * rfUid;
@property (retain, nonatomic) NSTimer * bleTimer;
@property id<FloBLEUartDelegate> delegate;

- (id)init;
- (void)startScan;
- (void)disconnectPeripheral:(CBPeripheral*)peripheral;
- (void) startScanningForUUIDString:(NSString *)uuidString;
- (void) startScanningForCBUUID:(CBUUID *)uuid;
- (void) discoverServicesForUUIDString:(CBPeripheral *)peripheral uuidString:(NSString *)uuidString;
- (void) discoverServicesForCBUUID:(CBPeripheral *)peripheral cbuuid:(CBUUID *)uuid;
- (void)delayStartScanTimerService:(NSTimer*)aTimer;
- (id)initWithDelegate:(id<FloBLEUartDelegate>)floBleDelegate;
- (void)writePeriperalWithResponse:(UInt8*)dataToWrite;
- (void)writePeriperalWithOutResponse:(UInt8*)dataToWrite;
- (void)writeBlockToPeriperalWithOutResponse:(UInt8*)dataToWrite ofLength:(UInt8)len;
- (protocolType_t)protocolType;

@end
