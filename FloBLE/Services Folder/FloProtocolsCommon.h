//
//  FloProtocolsCommon.h
//  FlobleOSX
//
//  Created by Chuck Carter on 12/3/14.
//  Copyright (c) 2014 Flomio. All rights reserved.
//

#ifndef FloProtocolsCommon_h
#define FlobProtocolsCommon_h


#endif

typedef enum : NSUInteger {
    Off = 0,
    On,
    Disconnected,
    Scanning,
    PeripheralDetected,
    Connected,
    Services,
    Badanamu
} deviceState_t;

typedef enum : NSUInteger {
    Unknown = 0,
    FloBLE, 
} protocolType_t;
