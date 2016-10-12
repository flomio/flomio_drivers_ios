//
//  FloBLEReader.m
//  Badanamu
//
//  Created by Chuck Carter on 10/13/14.
//  Copyright (c) 2014 Flomio. All rights reserved.
//

#import "FloBLEReader.h"
#import "FloProtocolsCommon.h"


NSString * const floReaderConnectionStatusChangeNotification = @"FloReaderConnectionsStatusChange";
NSInteger  nDiscoveredChars;

@interface FloBLEReader ()
{
    NSNotificationCenter * floReaderDeviceStateNotification;
}

@property (nonatomic, strong) NSNotificationCenter * floReaderDeviceStateNotification;


@end

@implementation FloBLEReader

@synthesize myCentralManager;
@synthesize activePeripheral;
@synthesize rfUid;
@synthesize serialF2hPortBlockCharacteristic;
@synthesize serialH2fPortBlockCharacteristic;
@synthesize oadServiceCharacteristic;
@synthesize oadImageIdentifyCharacteristic;
@synthesize oadImageBlockTransferCharacteristic;
@synthesize firmwareRevisionStringCharacteristic;
@synthesize arcBootServiceCharacteristic;
@synthesize bleTimer;
@synthesize deviceState = _deviceState;
@synthesize floReaderDeviceStateNotification;
@dynamic delegate; //@synthesize delegate;


#pragma - mark CBUUID Definitions

+ (CBUUID *) deviceInformationServiceUuid16bit
{
    return [CBUUID UUIDWithString:@"180A"];
}

+ (CBUUID *) oadServiceUuid16bit
{
    return [CBUUID UUIDWithString:@"FFC0"];
}

+ (CBUUID *) oadServiceUuid128bit
{
    return [CBUUID UUIDWithString:@"F000FFC0-0451-4000-B000-000000000000"];
}

+ (CBUUID *) floBleServiceUuid16bit
{
    return [CBUUID UUIDWithString:@"0001"];
}

+ (CBUUID *) floBleServiceUuid128bit
{
    return [CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) f2hBlockCharacteristicUuid128bit
{
    return [CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) h2fBlockCharacteristicUuid128bit
{
    return [CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) oadImageIdentifyCharacteristicUuid128bit
{
    return [CBUUID UUIDWithString:@"F000FFC1-0451-4000-B000-000000000000"];
}

+ (CBUUID *) oadImageBlockTransferCharacteristicUuid128bit
{
    return [CBUUID UUIDWithString:@"F000FFC2-0451-4000-B000-000000000000"];
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
        NSLog(@"inited FloBLEReader");
        myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
        rfUid = [[NSMutableArray alloc]initWithCapacity:30];
    }
    [self setDeviceState:Off];
    floReaderDeviceStateNotification = [NSNotificationCenter defaultCenter];
    return self;
}

- (id)initWithDelegate:(id<FloBLEReaderDelegate>)floBleDelegate
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
    NSLog(@"::centralManagerDidUpdateState supports %ld",[central state]);
    if([central state] == CBCentralManagerStatePoweredOn)
    {
       [self setDeviceState:On];
        [self startScan];

    }
    else
    {
        [self setDeviceState:Off];
    }
}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
{
        NSLog(@"::discovered peripheral %@ %@",[peripheral name],[peripheral identifier]);
    
        [self setDeviceState:PeripheralDetected];
    
        activePeripheral = peripheral;
        
        [myCentralManager connectPeripheral:peripheral options:nil];
}

/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"::didConnectPeripheral peripheral %@",[peripheral name]);
    peripheral.delegate = self;
    NSArray *uuidArray	= [NSArray arrayWithObjects:[FloBLEReader floBleServiceUuid128bit],[FloBLEReader oadServiceUuid128bit],[FloBLEReader deviceInformationServiceUuid16bit], nil];

    NSLog(@"starting discoverServicesForUUIDArray %@",uuidArray);
    [peripheral discoverServices:uuidArray];

    activePeripheral = peripheral;
    [self setDeviceState:Connected];
    [myCentralManager stopScan];
    NSLog(@"::Scanning stopped");
    nDiscoveredChars = 0;

}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self startScanningForCBUUID:[FloBLEReader floBleServiceUuid16bit]];
   NSLog(@"::didFailToConnectPeripheral peripheral %@",[peripheral name]);
}
/*------------------------------*/

- (void)peripheral:(CBPeripheral *)central didDiscoverServices:(NSError *)error;
{
    NSLog(@"::didDiscoverServices peripheral %@",[activePeripheral name]);
    for (CBService *service in activePeripheral.services)
    {
        NSLog(@"Discovered service %@ %@\n",service.peripheral, service.UUID);
        [activePeripheral discoverCharacteristics:nil forService:service];
    }
    
}

- (void)peripheral:(CBPeripheral *)central didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    CBUUID* myCharacteristicCUUID = [FloBLEReader f2hBlockCharacteristicUuid128bit];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"::Discovered f2HBlockcharacteristic %@",[characteristic UUID]);
            serialF2hPortBlockCharacteristic = characteristic;
            [activePeripheral setNotifyValue:YES forCharacteristic:serialF2hPortBlockCharacteristic];
            nDiscoveredChars |= 4;
            break;
        }
    }

    myCharacteristicCUUID = [FloBLEReader h2fBlockCharacteristicUuid128bit];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"::Discovered h2FBlockcharacteristic %@",[characteristic UUID]);
            serialH2fPortBlockCharacteristic = characteristic;
            nDiscoveredChars |= 8;
            break;
        }
    }

    myCharacteristicCUUID = [FloBLEReader oadImageIdentifyCharacteristicUuid128bit];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"::Discovered oadImageIdentifyCharacteristic %@",[characteristic UUID]);
            oadImageIdentifyCharacteristic = characteristic;
            [activePeripheral setNotifyValue:YES forCharacteristic:oadImageIdentifyCharacteristic];
            nDiscoveredChars |= 16;
            break;
        }
    }

    myCharacteristicCUUID = [FloBLEReader oadImageBlockTransferCharacteristicUuid128bit];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"::Discovered oadImageBlockTransferCharacteristic %@",[characteristic UUID]);
            oadImageBlockTransferCharacteristic = characteristic;
            [activePeripheral setNotifyValue:YES forCharacteristic:oadImageBlockTransferCharacteristic];
            nDiscoveredChars |= 32;
            break;
        }
    }
    
    if (nDiscoveredChars == 0x7F)
    {
        NSLog(@"::setDeviceState:Services %ld",(long)nDiscoveredChars);
        nDiscoveredChars = 0;
        [self setDeviceState:Services];
    }
}
/*------------------------------*/

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    static int nullNum = 0;
    NSData *myData = [characteristic value];
    //        NSLog(@"Characteristic value %@ ",[characteristic value]);
    //    NSLog(@"Characteristic isBroadcasted %hhd,",[characteristic isBroadcasted]);
    //    NSLog(@"Characteristic isNotifying %hhd,",[characteristic isNotifying]);
    
    if([characteristic isEqual:serialF2hPortBlockCharacteristic])
    {
        if (myData == nil)
        {
            NSLog(@":: Notification with NULL value serialF2hPortBlockCharacteristic");
            [self setDeviceState:Badanamu]; // going to do this here as a hack to retrieve uid on initial connection.
        }
        else
        {
           NSLog(@"::Notified serialF2hPortBlockCharacteristic %@", myData);
        }
    }
    else if([characteristic isEqual:oadImageIdentifyCharacteristic])
    {
        if (myData == nil)
        {
            NSLog(@":: Notification with NULL value oadImageIdentifyCharacteristic");
            [self setDeviceState:Badanamu]; // going to do this here as a hack to retrieve uid on initial connection.
        }
        else
        {
            NSLog(@"::Notified oadImageIdentifyCharacteristic %@", myData);
        }
    }
    else if([characteristic isEqual:oadImageBlockTransferCharacteristic])
    {
        if (myData == nil)
        {
            NSLog(@":: Notification with NULL value oadImageBlockTransferCharacteristic");
            [self setDeviceState:Badanamu]; // going to do this here as a hack to retrieve uid on initial connection.
        }
        else
        {
            NSLog(@"::Notified oadImageBlockTransferCharacteristic %@", myData);
        }
    }
    else
    {
        CBUUID *UUID = [characteristic UUID];
        NSLog(@":: Notification of Unsupported characteristic UUID %@",UUID);
    }
    //        [activePeripheral readValueForCharacteristic:characteristic];

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
    NSData *myData = [characteristic value];
    
    if([characteristic isEqual:serialF2hPortBlockCharacteristic] && myData)
    {
        if (myData == nil)
        {
            NSLog(@":: Update with NULL value for serialPortF2hBlockCharacteristic");
        }
        else
        {
            UInt8 * uartByte = (UInt8*)myData.bytes;
            BOOL parityGood = YES;
            for(int i = 0; i < myData.length; i++)
            {
            [self handleReceivedByte:uartByte[i] withParity:parityGood atTimestamp:[NSDate timeIntervalSinceReferenceDate]];
            }
            NSLog(@"::serialF2hPortBlockCharacteristic ReceivedBlock %2@",myData);
        }
    }
    else if([characteristic isEqual:oadImageIdentifyCharacteristic] && myData)
    {
        if (myData == nil)
        {
            NSLog(@":: Update with NULL value for oadImageIdentifyCharacteristic");
        }
        else
        {
            NSLog(@"::oadImageIdentifyCharacteristic ReceivedBlock %2@",myData);
            [self.delegate didReceivedImageIdentifyCharacteristic:myData];

        }
    }
    else if([characteristic isEqual:oadImageBlockTransferCharacteristic] && myData)
    {
        if (myData == nil)
        {
            NSLog(@":: Update with NULL value for oadImageBlockTransferCharacteristic");
        }
        else
        {
            NSLog(@"::oadImageBlockTransferCharacteristic ReceivedBlock %2@",myData);
            [self.delegate didReceivedImageBlockTransferCharacteristic:myData];

        }
    }
    else if([characteristic isEqual:firmwareRevisionStringCharacteristic] && myData)
    {
        if (myData == nil)
        {
            NSLog(@":: Update with NULL value for oadImageBlockTransferCharacteristic");
        }
        else
        {
            NSString * revisionString = [[NSString alloc]initWithData:myData encoding:NSASCIIStringEncoding];
            [self.delegate didReceiveServiceFirmwareVersion:revisionString];
        }
    }
   else
    {
        CBUUID *UUID = [characteristic UUID];
        NSLog(@":: Update of Unsupported characteristic UUID %@",UUID);
    }
}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Disconnected peripheral %@",[peripheral name]);
    
    serialF2hPortBlockCharacteristic = nil;
    serialH2fPortBlockCharacteristic = nil;
    oadServiceCharacteristic = nil;
    oadImageIdentifyCharacteristic = nil;
    oadImageBlockTransferCharacteristic = nil;
    firmwareRevisionStringCharacteristic = nil;

    [self setDeviceState:Disconnected];
    [self restartScanMode];
}


#pragma mark - floble control functions

- (void)startScan
{
    NSArray *uuidArray	= [NSArray arrayWithObjects:[FloBLEReader floBleServiceUuid16bit],[FloBLEReader oadServiceUuid16bit],[FloBLEReader deviceInformationServiceUuid16bit], nil];
    [self startScanningForCBUUIDs:uuidArray];
    NSLog(@"cc - starting scan\n");
    [self setDeviceState:Scanning];
}

/*------------------------------*/

- (void)disconnectPeripheral:(CBPeripheral*)peripheral
{
    [myCentralManager cancelPeripheralConnection:peripheral];
    [self setDeviceState:Disconnected];
}
/*------------------------------*/

- (void) startScanningForCBUUIDs:(NSArray *)uuidArray
{
    NSLog(@"starting scan UUID Array %@",uuidArray);
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
        [myCentralManager scanForPeripheralsWithServices:uuidArray options:options];
    [self setDeviceState:Scanning];
    
}

/*------------------------------*/
- (void)writePeriperalWithResponse:(UInt8*)dataToWrite
{
    if(serialH2fPortBlockCharacteristic)
    {
        NSData * value = [NSData dataWithBytes:(void*)dataToWrite length:1];
        [activePeripheral writeValue:value forCharacteristic:[self serialH2fPortBlockCharacteristic] type:CBCharacteristicWriteWithResponse];
    }
}

/*------------------------------*/
- (void)writeBlockToPeriperalWithOutResponse:(UInt8*)dataToWrite ofLength:(UInt8)len
{
    if(serialH2fPortBlockCharacteristic)
    {
        NSData * value = [NSData dataWithBytes:(void*)dataToWrite length:len];
        [activePeripheral writeValue:value forCharacteristic:[self serialH2fPortBlockCharacteristic] type:CBCharacteristicWriteWithoutResponse];
    }
}

/*------------------------------*/
- (void)writeBlockToOadImageIdentifyWithOutResponse:(UInt8*)dataToWrite ofLength:(UInt8)len
{
    if(oadImageIdentifyCharacteristic)
    {
        NSData * value = [NSData dataWithBytes:(void*)dataToWrite length:len];
        [activePeripheral writeValue:value forCharacteristic:[self oadImageIdentifyCharacteristic] type:CBCharacteristicWriteWithoutResponse];
    }
}

/*------------------------------*/
- (void)writeBlockToOadImageBlockTransferWithOutResponse:(UInt8*)dataToWrite ofLength:(UInt8)len
{
    if(oadImageBlockTransferCharacteristic)
    {
        NSData * value = [NSData dataWithBytes:(void*)dataToWrite length:len];
        [activePeripheral writeValue:value forCharacteristic:[self oadImageBlockTransferCharacteristic] type:CBCharacteristicWriteWithoutResponse];
    }
}


/*------------------------------*/

- (void)restartScanMode // background call
{
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
        [self startScan];
    }
}

#pragma mark - FLOReader overridden methods

- (BOOL)sendMessageDataToHost:(NSData *)messageData {
    UInt8 * uartByte = (UInt8*)messageData.bytes;
    int len = [messageData length];
    NSMutableString * string = [[NSMutableString alloc]init];

    for (int i = 0; i < len-1; i++)
    {
        [string appendString:[NSString stringWithFormat:@"%2.2x:",uartByte[i]]];
    }
    [string appendString:[NSString stringWithFormat:@"%2.2x",uartByte[len-1]]];
    NSLog(@"::Floble Reader sendMessageDataToHost %@",string);

    BOOL parityGood = YES;
   
#define maxTxBlockSize 16 // we have to break up long messages due to issue with TI BLE stack
    int ptr = 0;
    while (len)
    {
        if (len <= maxTxBlockSize)
        {
            [self writeBlockToPeriperalWithOutResponse:&uartByte[ptr] ofLength:len];
            len = 0;
        }
        else
        {
            [self writeBlockToPeriperalWithOutResponse:&uartByte[ptr] ofLength:maxTxBlockSize];
            ptr += maxTxBlockSize;
            len -= maxTxBlockSize;
        }
    }
    
    
    return true;
}

- (void)setDeviceState:(deviceState_t)deviceState
{
    _deviceState = deviceState;
    NSData * state = [NSData dataWithBytes:(const void*)&_deviceState length:1];
    NSDictionary * d = [NSDictionary dictionaryWithObject:state forKey:@"state"];
    [floReaderDeviceStateNotification postNotificationName:floReaderConnectionStatusChangeNotification object:self userInfo:d];

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
