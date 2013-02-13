//
//  NfcMessage.m
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FJMessage.h"

@implementation FJMessage {
    
}

@synthesize message     = _message;
@synthesize opcode      = _opcode;
@synthesize length      = _length;
@synthesize subOpcode   = _subOpcode;
@synthesize enable      = _enable;
@synthesize offset      = _offset;
@synthesize data        = _data;
@synthesize crc         = _crc;

@synthesize name        = _name;


- (id)init; {
    return [self initWithData:nil];        
}

- (id)initWithBytes:(UInt8 *)messageBytes; {
    unsigned int messageLength = (unsigned int) messageBytes[FLOJACK_MESSAGE_LENGTH_POSITION];
    NSData *message = [[NSData alloc] initWithBytes:messageBytes length:messageLength];
    
    return [self initWithData:message];
}

/**
 Designated initializer. Initialize the FloJack Message from an NSData object.
 
 @param theData        Data representing a FloJack message {opcode, length, ..., CRC}
 
 @return id
 */
- (id)initWithData:(NSData *)theData; {
    self = [super init];
    if (self) {
        if (theData != nil) {
            // Required message parameters
            _message = [theData copy];            
            [theData getBytes:&_opcode range:NSMakeRange(FLOJACK_MESSAGE_OPCODE_POSITION,
                                                         FLOJACK_MESSAGE_OPCODE_LENGTH)];
            [theData getBytes:&_length range:NSMakeRange(FLOJACK_MESSAGE_LENGTH_POSITION,
                                                            FLOJACK_MESSAGE_LENGTH_LENGTH)];
            [theData getBytes:&_crc range:NSMakeRange((theData.length - 1),
                                                      FLOJACK_MESSAGE_CRC_LENGTH)];
            
            // Optional message parameters
            _subOpcode = [FJMessage getMessageSubOpcode:theData];
            
            // variable declarations
            UInt8 flojackMessageEnable = 0;
            
            // Parse the message
            switch (_opcode) {
                case FLOMIO_STATUS_OP:
                    switch (_subOpcode) {
                        case FLOMIO_STATUS_ALL: {
                            _name = @"FLOMIO_STATUS_ALL";
                            break;
                        }
                        case FLOMIO_STATUS_HW_REV:  {
                            _name = @"FLOMIO_STATUS_HW_REV";
                            
                            NSRange dataRange = NSMakeRange((FLOJACK_MESSAGE_SUB_OPCODE_POSITION + 1),
                                                            theData.length - (FLOJACK_MESSAGE_SUB_OPCODE_POSITION + 2));
                            _data = [[NSData alloc] initWithData:[theData subdataWithRange:dataRange]];
                            break;
                        }
                        case FLOMIO_STATUS_SW_REV: {
                            _name = @"FLOMIO_STATUS_SW_REV";
                            
                            NSRange dataRange = NSMakeRange((FLOJACK_MESSAGE_SUB_OPCODE_POSITION + 1),
                                                            theData.length - (FLOJACK_MESSAGE_SUB_OPCODE_POSITION + 2));
                            _data = [[NSData alloc] initWithData:[theData subdataWithRange:dataRange]];
                            break;
                        }
                        case FLOMIO_STATUS_BATTERY:
                            _name = @"FLOMIO_STATUS_BATTERY";
                            break;
                        default:
                            break;
                    }
                    break;                
                case FLOMIO_PROTO_ENABLE_OP:
                    [theData getBytes:&flojackMessageEnable range:NSMakeRange(FLOJACK_MESSAGE_ENABLE_POSITION,
                                                                              FLOJACK_MESSAGE_ENABLE_LENGTH)];
                    switch (_subOpcode) {
                        case FLOMIO_PROTO_14443A:
                            switch (flojackMessageEnable) {
                                case FLOMIO_ENABLE:
                                    _name = @"FLOMIO_PROTO_14443A_ENABLE";
                                    _enable = TRUE;
                                    break;
                                case FLOMIO_DISABLE:
                                    _name = @"FLOMIO_PROTO_14443A_DISABLE";
                                    _enable = FALSE;
                                    break;
                            }
                            break;
                        case FLOMIO_PROTO_14443B:
                            switch (flojackMessageEnable) {
                                case FLOMIO_ENABLE:
                                    _name = @"FLOMIO_PROTO_14443B_ENABLE";
                                    _enable = TRUE;
                                    break;
                                case FLOMIO_DISABLE:
                                    _name = @"FLOMIO_PROTO_14443B_DISABLE";
                                    _enable = FALSE;
                                    break;
                            }
                            break;
                        case FLOMIO_PROTO_15693:
                            switch (flojackMessageEnable) {
                                case FLOMIO_ENABLE:
                                    _name = @"FLOMIO_PROTO_15693_ENABLE";
                                    _enable = TRUE;
                                    break;
                                case FLOMIO_DISABLE:
                                    _name = @"FLOMIO_PROTO_15693_DISABLE";
                                    _enable = FALSE;
                                    break;
                            }
                            break;
                        case FLOMIO_PORTO_FELICA:
                            switch (flojackMessageEnable) {
                                case FLOMIO_ENABLE:
                                    _name = @"FLOMIO_PORTO_FELICA_ENABLE";
                                    _enable = TRUE;
                                    break;
                                case FLOMIO_DISABLE:
                                    _name = @"FLOMIO_PORTO_FELICA_DISABLE";
                                    _enable = FALSE;
                                    break;
                            }
                            break;
                        default:
                            break;
                    }                    
                    break;
                case FLOMIO_POLLING_ENABLE_OP:
                    [theData getBytes:&flojackMessageEnable range:NSMakeRange(FLOJACK_MESSAGE_ENABLE_POSITION,
                                                                              FLOJACK_MESSAGE_ENABLE_LENGTH)];
                    switch (flojackMessageEnable) {
                        case FLOMIO_ENABLE:
                            _name = @"FLOMIO_POLLING_ENABLE_OP_ENABLE";
                            _enable = TRUE;
                            break;
                        case FLOMIO_DISABLE:
                            _name = @"FLOMIO_POLLING_ENABLE_OP_DISABLE";
                            _enable = FALSE;
                            break;
                        default:
                            break;
                    }
                    break;
                case FLOMIO_POLLING_RATE_OP:
                    _name = @"FLOMIO_POLLING_RATE_OP";
                    break;
                case FLOMIO_PING_OP:
                    _name = @"FLOMIO_PING_OP";
                    break;
                case FLOMIO_ACK_ENABLE_OP:
                    switch (_subOpcode) {
                        case FLOMIO_ACK_BAD:
                            _name = @"FLOMIO_ACK_BAD";
                            break;
                        case FLOMIO_ACK_GOOD:
                            _name = @"FLOMIO_ACK_GOOD";
                            break;
                        case FLOMIO_ENABLE:
                            _name = @"FLOMIO_ACK_ENABLE_OP_ENABLE";
                            _enable = TRUE;
                            break;
                        case FLOMIO_DISABLE:
                            _name = @"FLOMIO_ACK_ENABLE_OP_DISABLE";
                            _enable = FALSE;
                            break;
                        default:
                            break;
                    }
                    break;
                case FLOMIO_STANDALONE_OP:
                    switch (flojackMessageEnable) {
                        case FLOMIO_ENABLE:
                            _name = @"FLOMIO_STANDALONE_OP_ENABLE";
                            _enable = TRUE;
                            break;
                        case FLOMIO_DISABLE:
                            _name = @"FLOMIO_STANDALONE_OP_DISABLE";
                            _enable = FALSE;
                        default:
                            break;
                    }
                    break;
                case FLOMIO_STANDALONE_TIMEOUT_OP:
                    _name = @"FLOMIO_STANDALONE_TIMEOUT_OP";
                    break;
                case FLOMIO_DUMP_LOG_OP:
                    switch (_subOpcode) {
                        case FLOMIO_LOG_ALL:
                            _name = @"FLOMIO_LOG_ALL";
                            break;
                        default:
                            break;
                    }
                    break;
                case FLOMIO_TAG_READ_OP: {
                    _name = @"FLOMIO_TAG_READ_OP";
                                        
                    NSRange dataRange = NSMakeRange(FJ_TAG_UID_DATA_POS, (theData.length - 4));
                    _data = [[NSData alloc] initWithData:[theData subdataWithRange:dataRange]];                    
                    break;
                }
                case FLOMIO_BLOCK_READ_WRITE_OP:
                    switch (_subOpcode) {
                        case FLOMIO_READ_BLOCK:
                            _name = @"FLOMIO_READ_BLOCK";
                            
                            int dataLength = 0;
                            [theData getBytes:&dataLength range:NSMakeRange(FJ_BLOCK_RW_MSG_DATA_LENGTH_POS,
                                                                            FJ_BLOCK_RW_MSG_DATA_LENGTH_LEN)];
                            NSRange dataRange = NSMakeRange((FJ_BLOCK_RW_MSG_DATA_POS), dataLength);
                            _data = [[NSData alloc] initWithData:[theData subdataWithRange:dataRange]];
                            break;
                    }
                    break;
                case FLOMIO_TAG_WRITE_OP:
                    switch (_subOpcode) {
                        case FLOMIO_TAG_WRITE_STATUS_SUCCEEDED:
                            _name = @"FLOMIO_TAG_WRITE_OP Succeeded";
                        case FLOMIO_TAG_WRITE_STATUS_FAIL_TAG_UNSUPPORTED:
                            _name = @"FLOMIO_TAG_WRITE_OP Fail: Tag Unsupported";
                        case FLOMIO_TAG_WRITE_STATUS_FAIL_TAG_READ_ONLY:
                            _name = @"FLOMIO_TAG_WRITE_OP Fail: Tag R/O";
                        case FLOMIO_TAG_WRITE_STATUS_FAIL_TAG_NOT_ENOUGH_MEM:
                            _name = @"FLOMIO_TAG_WRITE_OP Fail: Tag Too Small";
                        case FLOMIO_TAG_WRITE_STATUS_FAIL_UNKOWN:
                            _name = @"FLOMIO_TAG_WRITE_OP Fail";
                            break;
                    }
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
        return [[NSData alloc] initWithData:[message subdataWithRange:NSMakeRange((FLOJACK_MESSAGE_SUB_OPCODE_POSITION + 1),
                                                                                  message.length - (FLOJACK_MESSAGE_SUB_OPCODE_POSITION + 2))]];
    } else {
        // Pop opcode, length, and remove CRC from end.
        return [[NSData alloc] initWithData:[message subdataWithRange:NSMakeRange((FLOJACK_MESSAGE_LENGTH_POSITION + 1),
                                                                                  message.length - (FLOJACK_MESSAGE_LENGTH_POSITION + 2))]];
    }
}


/**
 Return the message sub-opcode if it has one
 
 @param theMessage     The FloJack message
 
 @return UInt8         The sub-opcode or nil. 
 */
+ (UInt8)getMessageSubOpcode:(NSData *)theMessage; {
    UInt8 flojackMessageOpcode = 0;
    [theMessage getBytes:&flojackMessageOpcode range:NSMakeRange(FLOJACK_MESSAGE_OPCODE_POSITION,
                                                              FLOJACK_MESSAGE_OPCODE_LENGTH)];
    
    if (flojackMessageOpcode == FLOMIO_STATUS_OP ||
            flojackMessageOpcode == FLOMIO_PROTO_ENABLE_OP ||
            //flojackMessageOpcode == FLOMIO_POLLING_ENABLE_OP ||
            //flojackMessageOpcode == FLOMIO_POLLING_RATE_OP ||
            flojackMessageOpcode == FLOMIO_TAG_READ_OP ||
            flojackMessageOpcode == FLOMIO_ACK_ENABLE_OP ||
            //flojackMessageOpcode == FLOMIO_STANDALONE_OP ||
            //flojackMessageOpcode == FLOMIO_STANDALONE_TIMEOUT_OP ||
            //flojackMessageOpcode == FLOMIO_DUMP_LOG_OP ||
            flojackMessageOpcode == FLOMIO_LED_CONTROL_OP ||
            //flojackMessageOpcode == FLOMIO_TI_HOST_COMMAND_OP ||
            flojackMessageOpcode == FLOMIO_COMMUNICATION_CONFIG_OP ||
            flojackMessageOpcode == FLOMIO_PING_OP ||
            flojackMessageOpcode == FLOMIO_OPERATION_MODE_OP ||
            flojackMessageOpcode == FLOMIO_BLOCK_READ_WRITE_OP ||
            flojackMessageOpcode == FLOMIO_TAG_WRITE_OP)
    {
        UInt8 flojackMessageSubOpcode = 0;
        [theMessage getBytes:&flojackMessageSubOpcode range:NSMakeRange(FLOJACK_MESSAGE_SUB_OPCODE_POSITION,
                                                                        FLOJACK_MESSAGE_SUB_OPCODE_LENGTH)];
        return flojackMessageSubOpcode;
        
    } else {
        return nil;
    }
}




@end
