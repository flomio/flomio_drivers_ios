//
//  FloBLEUart.m
//  Badanamu
//
//  Created by Chuck Carter on 10/13/14.
//  Copyright (c) 2014 Flomio. All rights reserved.
//

#import "FloBLEUart.h"

@implementation FloBLEUart


//NSString * myServiceUUIDString = GLOBAL_SERIAL_PASS_SERVICE_UUID;
//NSString * myCharacteristicUUIDString = GLOBAL_SERIAL_PASS_CHARACTERISTIC_UUID;

@synthesize myCentralManager;
@synthesize activePeripheral;
//@synthesize myServiceUUIDs;
@synthesize rfUid;
//@synthesize serialPortCharacteristic;
@synthesize serialPortF2hCharacteristic;
@synthesize serialPortH2fCharacteristic;
@synthesize bleTimer;
//@synthesize delegate;
@dynamic delegate;




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

+ (CBUUID *) deviceInformationServiceUUID
{
    return [CBUUID UUIDWithString:@"180A"];
}

+ (CBUUID *) hardwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A27"];
}

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"inited FloBLEUart");
        myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
        rfUid = [[NSMutableArray alloc]initWithCapacity:30];
    }
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSLog(@"FloBLE UART applicationDidFinishLaunching");
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark BLE callbacks
/*------------------------------*/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManagerDidUpdateState supports %d",[central state]);
    if([central state] == CBCentralManagerStatePoweredOn)
    {
        myState = YES;
//        [self.delegate updateLog:@"BLE Enabled\n"];
        [self startScanningForCBUUID:[FloBLEUart floBLEserviceUUID]];
    }
    else
    {
        myState = NO;
    }

}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
{
    
//    if([[peripheral name] isEqualToString:@"Bean"]) // Bean
        //    if([[peripheral name] isEqualToString:@"Simple BLE Peripher"]) // Simple BLE Peripher
//    {
//    [self.delegate updateLog:[NSString stringWithFormat:@"Disconnected %@\n",[peripheral name]]];

        NSLog(@"discovered peripheral %@",[peripheral name]);
        NSLog(@"discovered dictionary %@",advertisementData);
        
        [myCentralManager stopScan];
//    [self.delegate updateLog:[NSString stringWithFormat:@"Stopped Scanning.\n"]];
        NSLog(@"Scanning stopped");
        
        activePeripheral = peripheral;
        
        [myCentralManager connectPeripheral:peripheral options:nil];
        
//    }
//    else if([peripheral name])
//    {
        NSLog(@"discovered peripheral %@",[peripheral name]);
 //   }
}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    [self.delegate updateLog:[NSString stringWithFormat:@"Connected to %@\n",[peripheral name]]];
    NSLog(@"didConnectPeripheral peripheral %@",[peripheral name]);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
//    [self discoverServicesForUUIDString:peripheral uuidString:myServiceUUIDString];
    [self discoverServicesForCBUUID:peripheral cbuuid:[FloBLEUart floBLEserviceUUID]];
}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral peripheral %@",[peripheral name]);
    
}
/*------------------------------*/

- (void)peripheral:(CBPeripheral *)central didDiscoverServices:(NSError *)error;
{
//    NSLog(@"------------------");
//    [self.delegate updateLog:[NSString stringWithFormat:@"Discovered Services\n"]];
//    NSLog(@"didDiscoverServices peripheral %@",[activePeripheral name]);
    for (CBService *service in activePeripheral.services) {
        //        NSLog(@"Discovered service %@\n", service);
        [activePeripheral discoverCharacteristics:nil forService:service];
//        NSLog(@"------------------");
        
    }
    
}
/*------------------------------*/

- (void)peripheral:(CBPeripheral *)central didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    int i = 0;
//    CBUUID* myCharacteristicCUUID = [CBUUID UUIDWithString:myCharacteristicUUIDString];
    CBUUID* myCharacteristicCUUID = [FloBLEUart f2HcharacteristicUUID];
    
//    NSLog(@"Discovered service %@\n", service);
    for (CBCharacteristic *characteristic in service.characteristics)
    {
//        NSLog(@"------------------");
//        NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
//            NSLog(@"Discovered Serial Port Characteristic %@",[characteristic UUID]);
            serialPortF2hCharacteristic = characteristic;
            [activePeripheral readValueForCharacteristic:characteristic];
            //            [peripheral setNotifyValue:YES forCharacteristic:serial_pass_characteristic];
            [activePeripheral setNotifyValue:YES forCharacteristic:serialPortF2hCharacteristic];
            
        }
        i += 1;
    }

    myCharacteristicCUUID = [FloBLEUart h2FhcharacteristicUUID];
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //        NSLog(@"------------------");
        //        NSLog(@"Discovered characteristic %@\n", characteristic);
        if ([[characteristic UUID] isEqual:myCharacteristicCUUID]) { // Serial Port
            //            NSLog(@"Discovered Serial Port Characteristic %@",[characteristic UUID]);
            serialPortH2fCharacteristic = characteristic;
            [activePeripheral readValueForCharacteristic:characteristic];
            //            [peripheral setNotifyValue:YES forCharacteristic:serial_pass_characteristic];
 //           [activePeripheral setNotifyValue:YES forCharacteristic:serialPortH2fCharacteristic];
            
        }
        i += 1;
    }
    //    [activePeripheral readValueForCharacteristic:(CBCharacteristic *)]
    
}
/*------------------------------*/

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateNotificationStateForCharacteristic");
    if(!error)
    {
        if([characteristic isEqual:serialPortF2hCharacteristic])
        {
            //            NSLog(@"characteristic isEqual:serialPortCharacteristic");
//            [activePeripheral readValueForCharacteristic:characteristic];
        }
    }else
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
    static NSUInteger len = 30, count = 0, theChar[1];
    static BOOL logThee = NO;
    
    NSData *myData = [characteristic value];
    //    NSLog(@"----------------------");
        NSLog(@"Characteristic value %@ ",[characteristic value]);
    //    NSLog(@"Characteristic isBroadcasted %hhd,",[characteristic isBroadcasted]);
    //    NSLog(@"Characteristic isNotifying %hhd,",[characteristic isNotifying]);
    //    NSLog(@"----------------------");
    
    if([characteristic isEqual:serialPortF2hCharacteristic] && myData)
    {
       UInt8 * uartByte = (UInt8*)myData.bytes;
       BOOL parityGood = YES;
       [self handleReceivedByte:uartByte[0] withParity:parityGood atTimestamp:CACurrentMediaTime()];
        NSLog(@"handleReceivedByte %2.2x,",uartByte[0]);
    }
    else
    {
        NSLog(@"NULL received byte or wrong characteristic");
    }
    
#if 0
    if([peripheral identifier] == [activePeripheral identifier])
    {
//        NSLog(@"uuid %@",[peripheral identifier]);
    
    
        if(logThee)
        {
            if(len == 30)
            {
                myData = [characteristic value];
                [myData getBytes:theChar length:1];
                len = theChar[0];
                NSLog(@"Length %d",len);
            }
            else
            {
                [rfUid addObject:[characteristic value]];
                count++;
            }
        }
        else if([characteristic value])
        {
            //       [rfUid addObject:[characteristic value]];
            myData = [characteristic value];
            [myData getBytes:theChar length:1];
        
            if(theChar[0] == 0x01)
            {
                NSLog(@"0x01");
               /logThee = YES;
            }
        }

        if(count >= len)
        {
            logThee = NO;
            len = 30;
            count = 0;
//            [self.delegate updateLog:[NSString stringWithFormat:@"RFID UID = %@:%@:%@:%@:%@:%@:%@\n",[rfUid objectAtIndex:0],[rfUid objectAtIndex:1],[rfUid objectAtIndex:2],[rfUid objectAtIndex:3],[rfUid objectAtIndex:4],[rfUid objectAtIndex:5],[rfUid objectAtIndex:6]]];

            NSLog(@"RFID UID = %@:%@:%@:%@:%@:%@:%@",[rfUid objectAtIndex:0],[rfUid objectAtIndex:1],[rfUid objectAtIndex:2],[rfUid objectAtIndex:3],[rfUid objectAtIndex:4],[rfUid objectAtIndex:5],[rfUid objectAtIndex:6]);
            [self disconnectPeripheral:peripheral];
//            [self restartScanMode];
        }
    }
#endif
}
/*------------------------------*/

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
//    [self.delegate updateLog:[NSString stringWithFormat:@"Disconnected peripheral %@\n",[peripheral name]]];
    NSLog(@"Disconnected peripheral %@",[peripheral name]);
//    [self performSelectorInBackground:@selector(restartScanMode) withObject:nil];
    [self restartScanMode];
}


#pragma mark - floble control functions

- (void)startScan
{
    if(myState)
    {
        [myCentralManager scanForPeripheralsWithServices:nil options:nil];
        NSLog(@"starting scan");

    }
}

/*------------------------------*/

- (void)disconnectPeripheral:(CBPeripheral*)peripheral
{
    [myCentralManager cancelPeripheralConnection:peripheral];
}

/*------------------------------*/

- (void) startScanningForUUIDString:(NSString *)uuidString
{
    NSLog(@"starting scan %@",uuidString);
    NSArray			*uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
    //	NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
//    [self.delegate updateLog:@"Scanning for devices....\n"];
    
    [myCentralManager scanForPeripheralsWithServices:uuidArray options:nil];
    //    [myCentralManager scanForPeripheralsWithServices:uuidArray options:options];
}
/*------------------------------*/

- (void) startScanningForCBUUID:(CBUUID *)uuid
{
    NSLog(@"starting scan %@",uuid);
    NSArray			*uuidArray	= [NSArray arrayWithObjects:uuid, nil];
    //	NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
//    [self.delegate updateLog:@"Scanning for devices....\n"];

    [myCentralManager scanForPeripheralsWithServices:uuidArray options:nil];
    //    [myCentralManager scanForPeripheralsWithServices:uuidArray options:options];
    
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

    
     for (int i = 0; i < len; i++)
     {
     BOOL parityGood = YES;
//     [self writePeriperalWithResponse:&uartByte[i]];
         [self writePeriperalWithOutResponse:&uartByte[i]];
     }

    
    return true;
}

@end
