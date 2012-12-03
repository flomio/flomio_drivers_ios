//
//  NfcMessage.m
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FJMessage.h"

@implementation FJMessage


// Message Attributes
UInt8 opcode;
int size;
BOOL enable;
UInt8 crc;

// TODO
//      Currently this object doesn't do anything. Just a stub. Need to determine
//      what kind of support to offer each of these opcodes.
//      Eventually this object should come to be an OOB representation of all possible opcodes.
-(void) init:(NSArray *)message; {
    
    //check opcode
    switch ([[message objectAtIndex:FLOJACK_MESSAGE_OPCODE_POSITION] intValue]) {
        case FLOMIO_STATUS_OP:
            switch ([[message objectAtIndex:FLOJACK_MESSAGE_SUB_OPCODE_POSITION] intValue])
        {
            case FLOMIO_STATUS_ALL:
                break;
            case FLOMIO_STATUS_HW_REV:
                break;
            case FLOMIO_STATUS_SW_REV:
                break;
            case FLOMIO_STATUS_BATTERY:    //not currently supported
                //break; //intentional fall through
            default:
                //not currently supported
                break;
        }
            break;
        case FLOMIO_PROTO_ENABLE_OP:
            switch ([[message objectAtIndex:FLOJACK_MESSAGE_SUB_OPCODE_POSITION] intValue]) {
                case FLOMIO_PROTO_14443A:
                    switch ([[message objectAtIndex:FLOJACK_MESSAGE_ENABLE_POSITION] intValue]) {
                        case FLOMIO_ENABLE:
                            break;
                        case FLOMIO_DISABLE:
                            break;
                    }
                    break;
                case FLOMIO_PROTO_14443B:
                    switch ([[message objectAtIndex:FLOJACK_MESSAGE_ENABLE_POSITION] intValue]) {
                        case FLOMIO_ENABLE:
                            break;
                        case FLOMIO_DISABLE:
                            break;
                    }
                    break;
                case FLOMIO_PROTO_15693:
                    switch ([[message objectAtIndex:FLOJACK_MESSAGE_ENABLE_POSITION] intValue]) {
                        case FLOMIO_ENABLE:
                            break;
                        case FLOMIO_DISABLE:
                            break;
                    }
                    break;
                case FLOMIO_PORTO_FELICA:
                    switch ([[message objectAtIndex:FLOJACK_MESSAGE_ENABLE_POSITION] intValue]) {
                        case FLOMIO_ENABLE:
                            break;
                        case FLOMIO_DISABLE:
                            break;
                    }
                    break;
                default:
                    break;
            }
            
            break;
        case FLOMIO_POLLING_ENABLE_OP:
            switch ([[message objectAtIndex:FLOJACK_MESSAGE_ENABLE_POSITION] intValue]) {
                case FLOMIO_DISABLE:
                    break;
                case FLOMIO_ENABLE:
                    break;
                default:
                    break;
            }
            break;
        case FLOMIO_POLLING_RATE_OP:
            break;
        case FLOMIO_ACK_ENABLE_OP:
            switch ([[message objectAtIndex:FLOJACK_MESSAGE_ENABLE_POSITION] intValue]) {
                case FLOMIO_DISABLE:
                    break;
                case FLOMIO_ENABLE:
                    break;
                default:
                    break;
            }
            break;
        case FLOMIO_STANDALONE_OP:
            switch ([[message objectAtIndex:FLOJACK_MESSAGE_ENABLE_POSITION] intValue]) {
                case FLOMIO_DISABLE:
                    break;
                case FLOMIO_ENABLE:
                    break;
                default:
                    break;
            }
            break;
        case FLOMIO_STANDALONE_TIMEOUT_OP:
            break;
        case FLOMIO_DUMP_LOG_OP:
            switch ([[message objectAtIndex:FLOJACK_MESSAGE_SUB_OPCODE_POSITION] intValue]) {
                case FLOMIO_LOG_ALL:
                    break;
                default:
                    //not currently supported
                    break;
            }
            break;
        case FLOMIO_TAG_UID_OP:       //not supported by Accessory
            
            break;
            
            
            //            case FLOMIO_LED_CONTROL_OP:   //not currently supported
            //            default:
            //                //not currently supported
            //                break;
    }
    
    
}

@end
