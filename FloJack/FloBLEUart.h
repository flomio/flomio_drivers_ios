//
//  FloBLEUart.h
//  Badanamu
//
//  Created by Chuck Carter on 10/13/14.
//  Copyright (c) 2014 Flomio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "FJNFCService.h"
#import "FloBLEUart.h"

//#define PUNCHTHROUGHDESIGN_128_UUID(uuid16) @"A495" uuid16 @"-C5B1-4B44-B512-1370F02D74DE"
//#define GLOBAL_SERIAL_PASS_SERVICE_UUID                    PUNCHTHROUGHDESIGN_128_UUID(@"FF10")
//#define GLOBAL_SERIAL_PASS_CHARACTERISTIC_UUID             PUNCHTHROUGHDESIGN_128_UUID(@"FF11")

//extern NSString * myServiceUUIDString;
//extern NSString * myCharacteristicUUIDString;
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
//    CBCharacteristic * serialPortCharacteristic;
    CBCharacteristic * serialF2hPortCharacteristic;
    CBCharacteristic * serialPortH2fCharacteristic;
    BOOL myState;
    NSMutableArray * rfUid;
    NSTimer * bleTimer;
}

@property (strong, nonatomic) CBCentralManager * myCentralManager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (strong, nonatomic) CBCharacteristic * serialPortF2hCharacteristic;
@property (strong, nonatomic) CBCharacteristic * serialPortH2fCharacteristic;
@property (copy, nonatomic) NSMutableArray * rfUid;
@property (retain, nonatomic) NSTimer * bleTimer;
@property id<FloBLEUartDelegate> delegate;

//@property (strong, nonatomic) NSArray * myServiceUUIDs;
//@property (strong, nonatomic) NSArray * myCharacteristicUUIDs;

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
@end
