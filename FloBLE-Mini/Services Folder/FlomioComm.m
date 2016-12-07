//
//  NfcMessage.m
//
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FlomioComm.h"
#import "NSData+FJStringDisplay.h"

@implementation FJMessage 

@synthesize bytes           = _bytes;
@synthesize opcode          = _opcode;
@synthesize length          = _length;
@synthesize subOpcode       = _subOpcode;
@synthesize subOpcodeMSN    = _subOpcodeMSN;
@synthesize subOpcodeLSN    = _subOpcodeLSN;
@synthesize enable          = _enable;
@synthesize offset          = _offset;
@synthesize data            = _data;
@synthesize crc             = _crc;
@synthesize name            = _name;


- (id)init; {
    return [self initWithData:nil];        
}

- (id)initWithBytes:(UInt8 *)messageBytes; {
    unsigned int messageLength = (unsigned int) messageBytes[FLO_MESSAGE_LENGTH_POSITION];
    NSData *message = [[NSData alloc] initWithBytes:messageBytes length:messageLength];
    
    return [self initWithData:message];
}

- (id)initWithMessageParameters:(UInt8)opcode andSubOpcode:(UInt8)subOpcode andData:(NSData *)data; {
    UInt8 length = (data.length + 4);
    NSMutableData *message = [[NSMutableData alloc] initWithCapacity:length];
    
    [message appendBytes:&opcode length:1];
    
    [message appendBytes:&length length:1];
    
    [message appendBytes:&subOpcode length:1];
    
    [message appendData:data];
    
    UInt8 crc = [FJMessage calculateCRCForIncompleteMessage:message];
    [message appendBytes:&crc length:1];
    
    //NSLog(@"write message: %@", [message fj_asHexString]);
    
    return [self initWithData:message];
}

/**
 Designated initializer. Initialize the Reader Message from an NSData object.
 
 @param theData        Data representing a Reader message {opcode, length, ..., CRC}
 
 @return id
 */
- (id)initWithData:(NSData *)theData; {
    self = [super init];
    if (self) {
        if (theData != nil) {
            // Required message parameters
            _bytes = [theData copy];            
            [theData getBytes:&_opcode range:NSMakeRange(FLO_MESSAGE_OPCODE_POSITION,
                                                         FLO_MESSAGE_OPCODE_LENGTH)];
            [theData getBytes:&_length range:NSMakeRange(FLO_MESSAGE_LENGTH_POSITION,
                                                            FLO_MESSAGE_LENGTH_LENGTH)];
            [theData getBytes:&_crc range:NSMakeRange((theData.length - 1),
                                                      FLO_MESSAGE_CRC_LENGTH)];
            
            // Optional message parameters
            _subOpcode = [FJMessage getMessageSubOpcode:theData];
            _subOpcodeMSN = (_subOpcode >> 4) & 0x0F;
            _subOpcodeLSN = _subOpcode & 0x0F;
            
            // variable declarations
            UInt8 floMessageEnable = 0;
            
            // Parse the message
            switch (_opcode) {
                case FLOMIO_STATUS_OP:
                    switch (_subOpcode) {
                        case FLOMIO_STATUS_HW_REV:  {
                            _name = @"FLOMIO_STATUS_HW_REV";
                            
                            NSRange dataRange = NSMakeRange((FLO_MESSAGE_SUB_OPCODE_POSITION + 1),
                                                            theData.length - (FLO_MESSAGE_SUB_OPCODE_POSITION + 2));
                            _data = [[NSData alloc] initWithData:[theData subdataWithRange:dataRange]];
                            break;
                        }
                        case FLOMIO_STATUS_SW_REV: {
                            _name = @"FLOMIO_STATUS_SW_REV";
                            
                            NSRange dataRange = NSMakeRange((FLO_MESSAGE_SUB_OPCODE_POSITION + 1),
                                                            theData.length - (FLO_MESSAGE_SUB_OPCODE_POSITION + 2));
                            _data = [[NSData alloc] initWithData:[theData subdataWithRange:dataRange]];
                            break;
                        }
                        case FLOMIO_STATUS_BATTERY:
                            _name = @"FLOMIO_STATUS_BATTERY";
                            break;
                        case FLOMIO_STATUS_SNIFFTHRESH:  {
                            _name = @"FLOMIO_STATUS_SNIFFTHRESH";
                            
                            NSRange dataRange = NSMakeRange((FLO_MESSAGE_SUB_OPCODE_POSITION + 1),
                                                            theData.length - (FLO_MESSAGE_SUB_OPCODE_POSITION + 2));
                            _data = [[NSData alloc] initWithData:[theData subdataWithRange:dataRange]];
                            break;
                        }
                        case FLOMIO_STATUS_SNIFFCALIB:  {
                            _name = @"FLOMIO_STATUS_SNIFFCALIB";

                            NSRange dataRange = NSMakeRange((FLO_MESSAGE_SUB_OPCODE_POSITION + 1),
                                                            theData.length - (FLO_MESSAGE_SUB_OPCODE_POSITION + 2));
                            _data = [[NSData alloc] initWithData:[theData subdataWithRange:dataRange]];
                            break;
                        }
                        default:
                            break;
                    }
                    break;
                case FLOMIO_WRISTBAND_OP:
                    switch (_subOpcode) {
                        case WRISTBAND_SW1_EVT:
                            break;
                        case WRISTBAND_SW2_EVT:
                            break;
                        case WRISTBAND_SW3_EVT:
                            break;
                        case WRISTBAND_SW4_EVT:
                            break;
                        case WRISTBAND_ORIENTATION_EVT:
                            break;
                        case WRISTBAND_MOTION_EVT:
                            break;
                        case WRISTBAND_WIRELESS_CHARGING_EVT:
                            break;
                        default:
                            break;
                    }
                default:
                    break;
            }
        } else {
            _opcode = nil;
            _length = nil;
            _subOpcode = nil;
            _offset = nil;
            _data = nil;
            _crc = nil;            
        }        
    }
    return self;   
}

- (NSData *)getDataFromMessage:(NSData *)message withSubOpcode:(BOOL)messageHasSubOpcode {
    if (messageHasSubOpcode) {
        // Pop opcode, length, sub-opcode and remove CRC from end.
        return [[NSData alloc] initWithData:[message subdataWithRange:NSMakeRange((FLO_MESSAGE_SUB_OPCODE_POSITION + 1),
                                                                                  message.length - (FLO_MESSAGE_SUB_OPCODE_POSITION + 2))]];
    } else {
        // Pop opcode, length, and remove CRC from end.
        return [[NSData alloc] initWithData:[message subdataWithRange:NSMakeRange((FLO_MESSAGE_LENGTH_POSITION + 1),
                                                                                  message.length - (FLO_MESSAGE_LENGTH_POSITION + 2))]];
    }
}


/**
 Return the message sub-opcode if it has one
 
 @param theMessage     The FLO message
 
 @return UInt8         The sub-opcode or nil. 
 */
+ (UInt8)getMessageSubOpcode:(NSData *)theMessage; {
    UInt8 floMessageOpcode = 0;
    [theMessage getBytes:&floMessageOpcode range:NSMakeRange(FLO_MESSAGE_OPCODE_POSITION,
                                                              FLO_MESSAGE_OPCODE_LENGTH)];
    
    if (floMessageOpcode == FLOMIO_STATUS_OP ||
        floMessageOpcode == FLOMIO_WRISTBAND_OP ||
        floMessageOpcode == FLOMIO_BLE_OP ||
        floMessageOpcode == FLOMIO_NFC_OP)
    {
        UInt8 floMessageSubOpcode = 0;
        [theMessage getBytes:&floMessageSubOpcode range:NSMakeRange(FLO_MESSAGE_SUB_OPCODE_POSITION,
                                                                        FLO_MESSAGE_SUB_OPCODE_LENGTH)];
        return floMessageSubOpcode;
        
    } else {
        return nil;
    }
}

/**
 calculateCRCForIncompleteMessage()
 Calculate the CRC for the given byte array
 
 @param message             Byte array representing a Reader message {opcode, length, ...}.
 Does not include CRC byte.
 @param messageLength       Length of the Reader message
 
 @return void
 */
+ (UInt8)calculateCRCForIncompleteMessage:(UInt8[])theMessage withLength:(int)messageLength
{
    UInt8 crc=0;
    for (int i=0; i<messageLength; i++)
    {
        crc ^= theMessage[i];
    }
    return crc;
}

+ (UInt8)calculateCRCForIncompleteMessage:(NSData *)theData
{
    UInt8 *bytes = (UInt8 *) [theData bytes];
    return [FJMessage calculateCRCForIncompleteMessage:bytes withLength:theData.length];
}


@end
