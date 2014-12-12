//
//  FloBLEUart.m
//  Badanamu
//
//  Created by Chuck Carter on 10/13/14.
//  Copyright (c) 2014 Flomio. All rights reserved.
//

#import "FloBLEUart.h"
#import "FloProtocolsCommon.h"

NSString * const floBLEConnectionStatusChangeNotification = @"floBLEConnectionsStatusChange";

@interface FloBLEUart ()
{
    NSNotificationCenter * flobleDeviceStateNotification;
}

@property (nonatomic, strong) NSNotificationCenter * flobleDeviceStateNotification;


@end

@implementation FloBLEUart

@synthesize myCentralManager;
@synthesize activePeripheral;
@synthesize rfUid;
@synthesize serialPortF2hCharacteristic;
@synthesize serialPortH2fCharacteristic;
@synthesize serialF2hPortBlockCharacteristic;
@synthesize serialH2fPortBlockCharacteristic;
@synthesize bleTimer;
@synthesize deviceState = _deviceState;
@synthesize flobleDeviceStateNotification;
@dynamic delegate; //@synthesize delegate;




+ (CBUUID *) floBLEserviceUUID
{
    return [CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) f2HcharacteristicUUID
{
    return [CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) h2FhcharacteristicUUID
{
    return [CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) f2HBlockcharacteristicUUID
{
    return [CBUUID UUIDWithString:@"6e400004-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) h2FBlockcharacteristicUUID
{
    return [CBUUID UUIDWithString:@"6e400005-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) deviceInformationServiceUUID
{
    return [CBUUID UUIDWithString:@"180A"];
}

+ (CBUUID *) hardwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A27"];
}

- (protocolType_t)protocolType
{
    protocolType_t selfProtocol = FloBLE;
    return selfProtocol;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"inited FloBLEUart");
        myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
        rfUid = [[NSMutableArray alloc]initWithCapacity:30];
    }
    [self setDeviceState:Off];
    flobleDeviceStateNotification = [NSNotificationCenter defaultCenter];

    return self;
}

- (id)initWithDelegate:(id<FloBLEUartDelegate>)floBleDelegate
{
    self = [self init];
    if (self)
    {
        // super calls will init this       delegate = floBleDelegate;
    }
    return self;
}

#pragma mark BLE callbacks
/*------------------------------*/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManagerDidUpdateState supports %ld",(long)[central state]);
    if([central state] == CBCentralManagerStatePoweredOn)
    {
       [self setDeviceState:On];
//        [self.delegate updateLog:@"BLE Enabled\n"];
        [self startScanningForCBUUID:[FloBLEUart floBLEserviceUUID]];
    }
    else
    {
        [self setDeviceState:Off];
    }

}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
{
    
        NSLog(@"discovered peripheral %@",[peripheral name]);
//        NSLog(@"discovered dictionary %@",advertisementData);
        
        [myCentralManager stopScan];
       [self setDeviceState:PeripheralDetected];
        NSLog(@"Scanning stopped");
        
        activePeripheral = peripheral;
        
        [myCentralManager connectPeripheral:peripheral options:nil];
}

/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    [self.delegate updateLog:[NSString stringWithFormat:@"Connected to %@\n",[peripheral name]]];
    NSLog(@"didConnectPeripheral peripheral %@",[peripheral name]);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    [self discoverServicesForCBUUID:peripheral cbuuid:[FloBLEUart floBLEserviceUUID]];
    [self setDeviceState:Connected];
}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral peripheral %@",[peripheral name]);
    
}
/*------------------------------*/

- (void)peripheral:(CBPeripheral *)central didDiscoverServices:(NSError *)error;
{
//    [self.delegate updateLog:[NSString stringWithFormat:@"Discovered Services\n"]];
//    NSLog(@"didDiscoverServices peripheral %@",[activePeripheral name]);
    for (CBService *service in activePeripheral.services) {
        //        NSLog(@"Discovered service %@\n", service);
        [activePeripheral discoverCharacteristics:nil forService:service];
    }
    
}

- (void)peripheral:(CBPeripheral *)central didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    int i = 0;
    CBUUID* myCharacteristicCUUID = [FloBLEUart f2HcharacteristicUUID];
    
//    NSLog(@"Discovered service %@\n", service);
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"Discovered f2Hcharacteristic %@",[characteristic UUID]);
            serialPortF2hCharacteristic = characteristic;
            [activePeripheral readValueForCharacteristic:characteristic];
            [activePeripheral setNotifyValue:YES forCharacteristic:serialPortF2hCharacteristic];
            
        }
        i += 1;
    }

    myCharacteristicCUUID = [FloBLEUart h2FhcharacteristicUUID];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
//        NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
          NSLog(@"Discovered h2Fhcharacteristic %@",[characteristic UUID]);
            serialPortH2fCharacteristic = characteristic;
            [activePeripheral readValueForCharacteristic:characteristic];
 //         [activePeripheral setNotifyValue:YES forCharacteristic:serialPortH2fCharacteristic];
            
        }
        i += 1;
    }

    myCharacteristicCUUID = [FloBLEUart f2HBlockcharacteristicUUID];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
//                NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"Discovered f2HBlockcharacteristic %@",[characteristic UUID]);
            serialF2hPortBlockCharacteristic = characteristic;
            [activePeripheral readValueForCharacteristic:characteristic];
            [activePeripheral setNotifyValue:YES forCharacteristic:serialF2hPortBlockCharacteristic];
            
        }
        i += 1;
    }

    myCharacteristicCUUID = [FloBLEUart h2FBlockcharacteristicUUID];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //                NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"Discovered h2FBlockcharacteristic %@",[characteristic UUID]);
            serialH2fPortBlockCharacteristic = characteristic;
            [activePeripheral readValueForCharacteristic:characteristic];
            [activePeripheral setNotifyValue:NO forCharacteristic:serialH2fPortBlockCharacteristic];
            
        }
        i += 1;
    }
//    [activePeripheral readValueForCharacteristic:(CBCharacteristic *)]
    
}
/*------------------------------*/

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    NSLog(@"didUpdateNotificationStateForCharacteristic");
    if(1)//!error)
    {
        if([characteristic isEqual:serialPortF2hCharacteristic])
        {
            NSLog(@"notified characteristic isEqual:serialPortF2hCharacteristic");
//            [activePeripheral readValueForCharacteristic:characteristic];
        }
        else if([characteristic isEqual:serialF2hPortBlockCharacteristic])
        {
                        NSLog(@"notified characteristic serialF2hPortBlockCharacteristic");
//                        [activePeripheral readValueForCharacteristic:characteristic];
        }

    }
    else
    {
    }
}
/*------------------------------*/

- (void)peripheral:(CBPeripheral *)aPeripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didWriteValueForCharacteristic");
    if(error)
    {
        NSLog(@"Error writing characteristic %@",[error localizedDescription]);
    }else
    {
        NSLog(@"Writed value for characteristic %@",[characteristic value]);
    }
}

/*------------------------------*/

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
//    static NSUInteger len = 30, count = 0;
    
    NSData *myData = [characteristic value];
        NSLog(@"Characteristic value %@ ",[characteristic value]);
    //    NSLog(@"Characteristic isBroadcasted %hhd,",[characteristic isBroadcasted]);
    //    NSLog(@"Characteristic isNotifying %hhd,",[characteristic isNotifying]);
    
    if([characteristic isEqual:serialPortF2hCharacteristic] && myData)
    {
       UInt8 * uartByte = (UInt8*)myData.bytes;
       BOOL parityGood = YES;
       [self handleReceivedByte:uartByte[0] withParity:parityGood atTimestamp:[NSDate timeIntervalSinceReferenceDate]];
       NSLog(@"handleReceivedByte %2.2x,",uartByte[0]);
    }
    else if([characteristic isEqual:serialF2hPortBlockCharacteristic] && myData)
    {
        UInt8 * uartByte = (UInt8*)myData.bytes;
        BOOL parityGood = YES;
        for(int i = 0; i < myData.length; i++)
        {
            [self handleReceivedByte:uartByte[i] withParity:parityGood atTimestamp:[NSDate timeIntervalSinceReferenceDate]];
        }
        //       [self handleReceivedByte:uartByte[0] withParity:parityGood atTimestamp:[NSDate timeIntervalSinceReferenceDate]];
               NSLog(@"handleReceivedBlock %2@,",myData);
    }
    else
    {
        if (myData == nil) {
            NSLog(@"NULL value characteristic");
        }
        else
        {
           NSLog(@"Wrong characteristic");
        }
    }
}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
//    [self.delegate updateLog:[NSString stringWithFormat:@"Disconnected peripheral %@\n",[peripheral name]]];
    NSLog(@"Disconnected peripheral %@",[peripheral name]);
//    [self performSelectorInBackground:@selector(restartScanMode) withObject:nil];

    [self setDeviceState:Disconnected];
    [self restartScanMode];
}


#pragma mark - floble control functions

- (void)startScan
{
    if([self deviceState])
    {
        [myCentralManager scanForPeripheralsWithServices:nil options:nil];
        NSLog(@"cc - starting scan\n");
        [self setDeviceState:Scanning];
    }
}

/*------------------------------*/

- (void)disconnectPeripheral:(CBPeripheral*)peripheral
{
    [myCentralManager cancelPeripheralConnection:peripheral];
    [self setDeviceState:Disconnected];
}

/*------------------------------*/

- (void) startScanningForUUIDString:(NSString *)uuidString
{
    NSLog(@"starting scan %@",uuidString);
    NSArray			*uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
    	NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
//    [self.delegate updateLog:@"Scanning for devices....\n"];
    
//    [myCentralManager scanForPeripheralsWithServices:uuidArray options:nil];
    [myCentralManager scanForPeripheralsWithServices:uuidArray options:options];
    [self setDeviceState:Scanning];
}
/*------------------------------*/

- (void) startScanningForCBUUID:(CBUUID *)uuid
{
    NSLog(@"starting scan %@",uuid);
    NSArray			*uuidArray	= [NSArray arrayWithObjects:uuid, nil];
    	NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
//    [self.delegate updateLog:@"Scanning for devices....\n"];

//    [myCentralManager scanForPeripheralsWithServices:uuidArray options:nil];
    [myCentralManager scanForPeripheralsWithServices:uuidArray options:options];
    [self setDeviceState:Scanning];
    
}
/*------------------------------*/

- (void) discoverServicesForUUIDString:(CBPeripheral *)peripheral uuidString:(NSString *)uuidString
{
    NSLog(@"starting discoverServicesForUUIDString %@",uuidString);
    NSArray			*uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
    
    [peripheral discoverServices:uuidArray];
    
}
/*------------------------------*/

- (void) discoverServicesForCBUUID:(CBPeripheral *)peripheral cbuuid:(CBUUID *)uuid
{
    NSLog(@"starting discoverServicesForUUIDString %@",uuid);
    NSArray			*uuidArray	= [NSArray arrayWithObjects:uuid, nil];
    
    [peripheral discoverServices:uuidArray];
    
}

/*------------------------------*/
- (void)writePeriperalWithResponse:(UInt8*)dataToWrite
{
    NSData * value = [NSData dataWithBytes:(void*)dataToWrite length:1];
    [activePeripheral writeValue:value forCharacteristic:[self serialPortH2fCharacteristic] type:CBCharacteristicWriteWithResponse];

}

/*------------------------------*/
- (void)writePeriperalWithOutResponse:(UInt8*)dataToWrite
{
    NSData * value = [NSData dataWithBytes:(void*)dataToWrite length:1];
    [activePeripheral writeValue:value forCharacteristic:[self serialPortH2fCharacteristic] type:CBCharacteristicWriteWithoutResponse];
}

/*------------------------------*/
- (void)writeBlockToPeriperalWithOutResponse:(UInt8*)dataToWrite ofLength:(UInt8)len
{
    NSData * value = [NSData dataWithBytes:(void*)dataToWrite length:len];
    [activePeripheral writeValue:value forCharacteristic:[self serialH2fPortBlockCharacteristic] type:CBCharacteristicWriteWithoutResponse];
}

/*------------------------------*/

- (void)restartScanMode // background call
{
//    @autoreleasepool {
//        [self performSelectorOnMainThread:@selector(startScanningForCBUUID:) withObject:[FloBLEUart floBLEserviceUUID] waitUntilDone:YES];
//    }
    NSLog(@"starting delayStartScanTimerService");
    self.bleTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(delayStartScanTimerService:) userInfo:nil repeats:NO];

}
/*------------------------------*/

- (void)dealloc
{
    [myCentralManager stopScan];
     [self setDeviceState:Off];
    NSLog(@"dealloc");
    //    [self.disconectPeripheral:activePeripheral];
    //    [super dealloc];
}
/*------------------------------*/

- (void)delayStartScanTimerService:(NSTimer*)aTimer
{
    if (bleTimer == nil)
    {
        NSLog(@"timer not instantiated");
        return;
    }
    else
    {
       [self startScanningForCBUUID:[FloBLEUart floBLEserviceUUID]];
    }
}

#pragma mark - FJNFCService overridden methods

- (BOOL)sendMessageDataToHost:(NSData *)messageData {
    UInt8 * uartByte = (UInt8*)messageData.bytes;
    int len = [messageData length];
    NSMutableString * string = [[NSMutableString alloc]init];

    for (int i = 0; i < len-1; i++)
    {
        [string appendString:[NSString stringWithFormat:@"%2.2x:",uartByte[i]]];
    }
    [string appendString:[NSString stringWithFormat:@"%2.2x",uartByte[len-1]]];
    NSLog(@"Floble sendMessageDataToHost %@",string);

//    BOOL parityGood = YES;
   
//     for (int i = 0; i < len; i++)
//     {
//     [self writePeriperalWithResponse:&uartByte[i]];
//       [self writePeriperalWithOutResponse:&uartByte[i]];

//     }
    [self writeBlockToPeriperalWithOutResponse:uartByte ofLength:len];

    
    return true;
}

- (void)setDeviceState:(deviceState_t)deviceState
{
    _deviceState = deviceState;
    NSData * state = [NSData dataWithBytes:(const void*)&_deviceState length:1];
    NSDictionary * d = [NSDictionary dictionaryWithObject:state forKey:@"state"];
    [flobleDeviceStateNotification postNotificationName:floBLEConnectionStatusChangeNotification object:self userInfo:d];

    if(_deviceState == Connected)
    {
        super.deviceConnected = YES;
    }
    else
    {
        super.deviceConnected = NO;
    }
}

- (deviceState_t)deviceState
{
    return _deviceState;
}


@end
