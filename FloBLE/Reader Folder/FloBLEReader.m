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
@synthesize serialPortF2hCharacteristic;
@synthesize serialPortH2fCharacteristic;
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

+ (CBUUID *) floBLEserviceUUID
{
    return [CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) floBLEserviceUUID_03 {
    return [CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) floBLEserviceUUID_04 {
    return [CBUUID UUIDWithString:@"6e400004-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) floBLEserviceUUID_08 {
    return [CBUUID UUIDWithString:@"6e400008-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) floBLEserviceUUID_11 {
    return [CBUUID UUIDWithString:@"6e400011-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) floBLEserviceUUID_12 {
    return [CBUUID UUIDWithString:@"6e400012-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) floBLEserviceUUID_13 {
    return [CBUUID UUIDWithString:@"6e400013-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) floBLEserviceUUID_14 {
    return [CBUUID UUIDWithString:@"6e400014-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) floBLEserviceUUID_19 {
    return [CBUUID UUIDWithString:@"6e400019-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) floBLEserviceUUID_20 {
    return [CBUUID UUIDWithString:@"6e400020-b5a3-f393-e0a9-e50e24dcca9e"];
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

+ (CBUUID *) firmwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A26"];
}

+ (CBUUID *) softwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A28"];
}

+ (CBUUID *) oadServiceUUID
{
    return [CBUUID UUIDWithString:@"F000FFC0-0451-4000-B000-000000000000"];
}

+ (CBUUID *) oadImageIdentifyCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"F000FFC1-0451-4000-B000-000000000000"];
}

+ (CBUUID *) oadImageBlockTransferCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"F000FFC2-0451-4000-B000-000000000000"];
}

+ (CBUUID *) arcBootServiceUUID
{
//    return [CBUUID UUIDWithString:@"F000FFF0-0451-4000-B000-000000000000"];
    return [CBUUID UUIDWithString:@"FFF0"];
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
//        NSLog(@"::discovered dictionary %@",advertisementData);
        
       [self setDeviceState:PeripheralDetected];
    
        activePeripheral = peripheral;
        
        [myCentralManager connectPeripheral:peripheral options:nil];
}

/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    [self.delegate updateLog:[NSString stringWithFormat:@"Connected to %@\n",[peripheral name]]];
    NSLog(@"::didConnectPeripheral peripheral %@",[peripheral name]);
    peripheral.delegate = self;
//    [peripheral discoverServices:nil];
 //   [self discoverServicesForCBUUID:peripheral cbuuid:[FloBLEReader floBLEserviceUUID]];
//    [self discoverServicesForCBUUID:peripheral cbuuid:[FloBLEReader oadServiceUUID]];
//    NSArray *uuidArray	= [NSArray arrayWithObjects:[FloBLEReader floBLEserviceUUID],[FloBLEReader floBLEserviceUUID_11],[FloBLEReader floBLEserviceUUID_12],[FloBLEReader floBLEserviceUUID_13],[FloBLEReader floBLEserviceUUID_14],[FloBLEReader floBLEserviceUUID_19],[FloBLEReader floBLEserviceUUID_20],[FloBLEReader oadServiceUUID],[FloBLEReader deviceInformationServiceUUID], nil];
    NSArray *uuidArray	= [NSArray arrayWithObjects:[FloBLEReader floBLEserviceUUID],[FloBLEReader oadServiceUUID],[FloBLEReader deviceInformationServiceUUID], nil];

    [self discoverServicesForCBUUID:peripheral withCBUUIDs:uuidArray];
        //    NSLog(@"starting discoverServicesForUUIDString %@",uuid);
        //    NSArray			*uuidArray	= [NSArray arrayWithObjects:uuid, nil];

    activePeripheral = peripheral;
   [self setDeviceState:Connected];
    [myCentralManager stopScan];
    NSLog(@"::Scanning stopped");
    nDiscoveredChars = 0;

}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self startScanningForCBUUID:[FloBLEReader floBLEserviceUUID]];
//    [self startScanningForCBUUID:[FloBLEReader oadServiceUUID]];
   NSLog(@"::didFailToConnectPeripheral peripheral %@",[peripheral name]);
}
/*------------------------------*/

- (void)peripheral:(CBPeripheral *)central didDiscoverServices:(NSError *)error;
{
//    [self.delegate updateLog:[NSString stringWithFormat:@"Discovered Services\n"]];
    NSLog(@"::didDiscoverServices peripheral %@",[activePeripheral name]);
    for (CBService *service in activePeripheral.services)
    {
            NSLog(@"Discovered service %@ %@\n",service.peripheral, service.UUID);
    [activePeripheral discoverCharacteristics:nil forService:service];
    }
    
}

- (void)peripheral:(CBPeripheral *)central didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    CBUUID* myCharacteristicCUUID = [FloBLEReader f2HcharacteristicUUID];
//    NSLog(@"Discovered service %@\n", service);
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"::Discovered f2Hcharacteristic %@",[characteristic UUID]);
            serialPortF2hCharacteristic = characteristic;
//            [activePeripheral readValueForCharacteristic:characteristic];
            [activePeripheral setNotifyValue:YES forCharacteristic:serialPortF2hCharacteristic];
            nDiscoveredChars |= 1;
            break;
        }
    }

    myCharacteristicCUUID = [FloBLEReader h2FhcharacteristicUUID];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
//        NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
          NSLog(@"::Discovered h2Fhcharacteristic %@",[characteristic UUID]);
            serialPortH2fCharacteristic = characteristic;
//            [activePeripheral readValueForCharacteristic:characteristic];
//          [activePeripheral setNotifyValue:NO forCharacteristic:serialPortH2fCharacteristic];
            nDiscoveredChars |= 2;
            break;
        }
    }

    myCharacteristicCUUID = [FloBLEReader f2HBlockcharacteristicUUID];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
//                NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"::Discovered f2HBlockcharacteristic %@",[characteristic UUID]);
            serialF2hPortBlockCharacteristic = characteristic;
//            [activePeripheral readValueForCharacteristic:characteristic];
            [activePeripheral setNotifyValue:YES forCharacteristic:serialF2hPortBlockCharacteristic];
            nDiscoveredChars |= 4;
            break;
        }
    }

    myCharacteristicCUUID = [FloBLEReader h2FBlockcharacteristicUUID];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //                NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"::Discovered h2FBlockcharacteristic %@",[characteristic UUID]);
            serialH2fPortBlockCharacteristic = characteristic;
//            [activePeripheral readValueForCharacteristic:characteristic];
//            [activePeripheral setNotifyValue:NO forCharacteristic:serialH2fPortBlockCharacteristic];
            nDiscoveredChars |= 8;
            break;
        }
    }
//    [activePeripheral readValueForCharacteristic:(CBCharacteristic *)];

    myCharacteristicCUUID = [FloBLEReader oadImageIdentifyCharacteristicUUID];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //                NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"::Discovered oadImageIdentifyCharacteristic %@",[characteristic UUID]);
            oadImageIdentifyCharacteristic = characteristic;
            //            [activePeripheral readValueForCharacteristic:characteristic];
            [activePeripheral setNotifyValue:YES forCharacteristic:oadImageIdentifyCharacteristic];
            nDiscoveredChars |= 16;
            break;
        }
    }
    //    [activePeripheral readValueForCharacteristic:(CBCharacteristic *)];

    myCharacteristicCUUID = [FloBLEReader oadImageBlockTransferCharacteristicUUID];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //                NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            NSLog(@"::Discovered oadImageBlockTransferCharacteristic %@",[characteristic UUID]);
            oadImageBlockTransferCharacteristic = characteristic;
            //            [activePeripheral readValueForCharacteristic:characteristic];
            [activePeripheral setNotifyValue:YES forCharacteristic:oadImageBlockTransferCharacteristic];
            nDiscoveredChars |= 32;
            break;
        }
    }
    //    [activePeripheral readValueForCharacteristic:(CBCharacteristic *)];

    myCharacteristicCUUID = [FloBLEReader firmwareRevisionStringUUID];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //                NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID])
        {
            NSLog(@"::Discovered deviceInformationService %@",[characteristic UUID]);
            firmwareRevisionStringCharacteristic = characteristic;
            //            [activePeripheral readValueForCharacteristic:characteristic];
            [activePeripheral setNotifyValue:NO forCharacteristic:firmwareRevisionStringCharacteristic];
            nDiscoveredChars |= 64;
            [activePeripheral readValueForCharacteristic:firmwareRevisionStringCharacteristic];
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
    
    if([characteristic isEqual:serialPortF2hCharacteristic])
    {

        if (myData == nil)
        {
            NSLog(@":: Notification with NULL value serialPortF2hCharacteristic");
        }
        else
        {
            NSLog(@"::Notified serialPortF2hCharacteristic %@", myData);
        }
    }
    else if([characteristic isEqual:serialF2hPortBlockCharacteristic])
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
//    static NSUInteger len = 30, count = 0;
    
    NSData *myData = [characteristic value];
//        NSLog(@"Characteristic value %@ ",[characteristic value]);
    //    NSLog(@"Characteristic isBroadcasted %hhd,",[characteristic isBroadcasted]);
    //    NSLog(@"Characteristic isNotifying %hhd,",[characteristic isNotifying]);
    
    if([characteristic isEqual:serialPortF2hCharacteristic] && myData)
    {
        if (myData == nil)
        {
            NSLog(@":: Update with NULL value for serialPortF2hCharacteristic");
        }
        else
        {
            UInt8 * uartByte = (UInt8*)myData.bytes;
            BOOL parityGood = YES;
            [self handleReceivedByte:uartByte[0] withParity:parityGood atTimestamp:[NSDate timeIntervalSinceReferenceDate]];
            NSLog(@"::serialPortF2hCharacteristic ReceivedByte %2.2x",uartByte[0]);
        }
    }
    else if([characteristic isEqual:serialF2hPortBlockCharacteristic] && myData)
    {
        if (myData == nil)
        {
            NSLog(@":: Update with NULL value for serialPortF2hCharacteristic");
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
//            UInt8 * uartByte = (UInt8*)myData.bytes;
//            BOOL parityGood = YES;
//            for(int i = 0; i < myData.length; i++)
//            {
//                [self handleReceivedByte:uartByte[i] withParity:parityGood atTimestamp:[NSDate timeIntervalSinceReferenceDate]];
//            }
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
//            UInt8 * uartByte = (UInt8*)myData.bytes;
//            BOOL parityGood = YES;
//            for(int i = 0; i < myData.length; i++)
//            {
                //                [self handleReceivedByte:uartByte[i] withParity:parityGood atTimestamp:[NSDate timeIntervalSinceReferenceDate]];
//            }
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
//            UInt8 * uartByte = (UInt8*)myData.bytes;
//            BOOL parityGood = YES;
            NSString * revisionString = [[NSString alloc]initWithData:myData encoding:NSASCIIStringEncoding];
//            for(int i = 0; i < myData.length; i++)
//            {
                //                [self handleReceivedByte:uartByte[i] withParity:parityGood atTimestamp:[NSDate timeIntervalSinceReferenceDate]];
//            }
//            NSLog(@"::firmwareRevisionStringCharacteristic ReceivedBlock %@",revisionString);
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
//    [self.delegate updateLog:[NSString stringWithFormat:@"Disconnected peripheral %@\n",[peripheral name]]];
    NSLog(@"Disconnected peripheral %@",[peripheral name]);
//    [self performSelectorInBackground:@selector(restartScanMode) withObject:nil];
    
    serialPortF2hCharacteristic = nil;
    serialPortH2fCharacteristic = nil;
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
    //-        [self.delegate updateLog:@"BLE Enabled\n"];
    //        [self startScanningForCBUUID:[FloBLEReader floBLEserviceUUID]];
    //        [self startScanningForCBUUID:[FloBLEReader oadServiceUUID]];
    //        [self startScanningForCBUUID:[FloBLEReader arcBootServiceUUID]];
//    NSArray * uuidArray = [NSArray arrayWithObjects:[FloBLEReader floBLEserviceUUID],[FloBLEReader floBLEserviceUUID_11],[FloBLEReader floBLEserviceUUID_12],[FloBLEReader floBLEserviceUUID_13],[FloBLEReader floBLEserviceUUID_14],[FloBLEReader floBLEserviceUUID_19],[FloBLEReader floBLEserviceUUID_20],[FloBLEReader oadServiceUUID],[FloBLEReader arcBootServiceUUID], nil];
    NSArray *uuidArray	= [NSArray arrayWithObjects:[FloBLEReader floBLEserviceUUID],[FloBLEReader oadServiceUUID],[FloBLEReader deviceInformationServiceUUID], nil];
    [self startScanningForCBUUIDs:uuidArray];
    //          [self startScanningForCBUUIDs:nil];
    //        [myCentralManager scanForPeripheralsWithServices:nil options:nil];
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

- (void) startScanningForUUIDString:(NSString *)uuidString
{
    NSLog(@"starting scan %@",uuidString);
    NSArray			*uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
    	NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
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
    	NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
//    [self.delegate updateLog:@"Scanning for devices....\n"];

//    [myCentralManager scanForPeripheralsWithServices:uuidArray options:nil];
    [myCentralManager scanForPeripheralsWithServices:uuidArray options:options];
    [self setDeviceState:Scanning];
    
}
/*------------------------------*/

- (void) startScanningForCBUUIDs:(NSArray *)uuidArray
{
    NSLog(@"starting scan %@",uuidArray);
    NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
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
//    [peripheral discoverServices:nil];
   
}
- (void) discoverServicesForCBUUID:(CBPeripheral *)peripheral withCBUUIDs:(NSArray *)uuidArray
{
//    NSLog(@"starting discoverServicesForUUIDString %@",uuid);
//    NSArray			*uuidArray	= [NSArray arrayWithObjects:uuid, nil];
    
    [peripheral discoverServices:uuidArray];
    //    [peripheral discoverServices:nil];
    
}

/*------------------------------*/
- (void)writePeriperalWithResponse:(UInt8*)dataToWrite
{
    if(serialPortH2fCharacteristic)
    {
        NSData * value = [NSData dataWithBytes:(void*)dataToWrite length:1];
        [activePeripheral writeValue:value forCharacteristic:[self serialPortH2fCharacteristic] type:CBCharacteristicWriteWithResponse];
    }
}

/*------------------------------*/
- (void)writePeriperalWithOutResponse:(UInt8*)dataToWrite
{
    if(serialPortH2fCharacteristic)
    {
        NSData * value = [NSData dataWithBytes:(void*)dataToWrite length:1];
        [activePeripheral writeValue:value forCharacteristic:[self serialPortH2fCharacteristic] type:CBCharacteristicWriteWithoutResponse];
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
//    @autoreleasepool {
//        [self performSelectorOnMainThread:@selector(startScanningForCBUUID:) withObject:[FloBLEReader floBLEserviceUUID] waitUntilDone:YES];
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
        [self startScan]; //[self startScanningForCBUUID:[FloBLEReader floBLEserviceUUID]];
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
   
//     for (int i = 0; i < len; i++)
//     {
//     [self writePeriperalWithResponse:&uartByte[i]];
//       [self writePeriperalWithOutResponse:&uartByte[i]];

//     }
#define maxTxBlockSize 20 // we have to break up long messages due to issue with TI BLE stack
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
