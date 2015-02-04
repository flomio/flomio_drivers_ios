//
//  FLOReaderManager.m
//
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FLOReaderManager.h"
//#import "ViewController.h"

@implementation FLOReaderManager {
    id <FLOReaderManagerDelegate>       _delegate;
//    FLOReader                    *_nfcService;
    FloBLEReader                    *_nfcService;
    NSMutableData                   *_lastMessageSent;
}

@synthesize delegate = _delegate;
@synthesize pollFor14443aTags = _pollFor14443aTags;
@synthesize pollFor15693Tags = _pollFor15693Tags;
@synthesize pollForFelicaTags = _pollForFelicaTags;
@synthesize standaloneMode = _standaloneMode;
;

/**
 Designated intializer of FLOReaderManager.  Should be overloaded by Client App to have custom config context in place.
 
 @return FLOReaderManager
 */
- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"FLOReaderManager init");

//        _nfcService = [[FLOReader alloc] init];
        _nfcService = [[FloBLEReader alloc] init];
        [_nfcService setDelegate:self];
        
        _lastMessageSent = [[NSMutableData alloc] initWithCapacity:MAX_MESSAGE_LENGTH];
        _pollFor14443aTags =  true;
        _pollFor15693Tags =  true;
        _pollForFelicaTags =  false;
        _standaloneMode = false;
        
        NSLog(@"Protocol Type: %u",[_nfcService protocolType]);

    }
    return self;
}

/**
 Get Reader Firmware version
 
 @return void
 */
- (void)getFirmwareVersion {
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_STATUS_OP
                                                                andSubOpcode:FLOMIO_STATUS_SW_REV
                                                                andData:nil];
    [self sendMessageDataToHost:floMessage.bytes];
    NSLog(@"getFirmwareVersion");
}

/**
 Get Reader Hardware version
 
 @return void
 */
- (void)getHardwareVersion {
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_STATUS_OP
                                                                andSubOpcode:FLOMIO_STATUS_HW_REV
                                                                andData:nil];
    [self sendMessageDataToHost:floMessage.bytes];
}

/**
 Get Reader Sniffer Threshold value
 
 @return void
 */
- (void)getSnifferThresh {
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_STATUS_OP
                                                                andSubOpcode:FLOMIO_STATUS_SNIFFTHRESH
                                                                     andData:nil];
    [self sendMessageDataToHost:floMessage.bytes];
}

/**
 Get Reader Sniffer Calibration numbers.  18 words of data.  They include the
 Sniffer Threshold, Sniffer Max and 16 calibration values from reset (power cycle).
 
 @return void
*/
- (void)getSnifferCalib {
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_STATUS_OP
                                                                andSubOpcode:FLOMIO_STATUS_SNIFFCALIB
                                                                andData:nil];
    [self sendMessageDataToHost:floMessage.bytes];
}



/**
 Parses an NSData object for a Reader message and handles it accordingly. 
 
 @param NSData Byte stream to be parsed.
 @return void
 */
- (void)parseMessage:(NSData *)message;
{
    FJMessage *floMessage = [[FJMessage alloc] initWithData:message];
    UInt8 floMessageOpcode = floMessage.opcode;
    UInt8 floMessageSubOpcode = floMessage.subOpcode;
    NSData *messageData = [floMessage.data copy];
    UInt8 floMessageLen = floMessage.length;
    
    switch (floMessageOpcode) {
        case FLOMIO_STATUS_OP: {
            switch (floMessageSubOpcode) {
                case FLOMIO_STATUS_HW_REV: {
                    LogInfo(@"FLOMIO_STATUS_HW_REV ");
                    NSString *hardwareVersion = [NSString stringWithFormat:@"%@", [messageData fj_asHexString]];
                    
                    if ([_delegate respondsToSelector:@selector(floReaderManager: didReceiveHardwareVersion:)]) {
                        [_delegate floReaderManager:self didReceiveHardwareVersion:hardwareVersion];
                    }
                    break;
                }
                case FLOMIO_STATUS_SW_REV: {
                    LogInfo(@"FLOMIO_STATUS_SW_REV ");
                    NSString *firmwareVersion = [NSString stringWithFormat:@"%@", [messageData fj_asHexString]];
                    
                    if ([_delegate respondsToSelector:@selector(floReaderManager: didReceiveFirmwareVersion:)]) {
                        [_delegate floReaderManager:self didReceiveFirmwareVersion:firmwareVersion];
                    }
                    break;
                }
                case FLOMIO_STATUS_SNIFFTHRESH: {
                    LogInfo(@"FLOMIO_STATUS_SNIFFTHRESH ");
                    NSString *snifferValue = [NSString stringWithFormat:@"%@", [messageData fj_asHexString]];
                
                    if ([_delegate respondsToSelector:@selector(floReaderManager: didReceiveSnifferThresh:)]) {
                        [_delegate floReaderManager:self didReceiveSnifferThresh:snifferValue];
                    }
                    break;
                }
                case FLOMIO_STATUS_SNIFFCALIB: {
                    LogInfo(@"FLOMIO_STATUS_SNIFFCALIB ");
                    NSString *calibValues = [NSString stringWithFormat:@"%@", [messageData fj_asHexWordStringWithSpace]];
                    
                    if ([_delegate respondsToSelector:@selector(floReaderManager: didReceiveSnifferCalib:)]) {
                        [_delegate floReaderManager:self didReceiveSnifferCalib:calibValues];
                    }
                    break;
                }
                case FLOMIO_STATUS_ALL: {
                    break;
                }
                case FLOMIO_STATUS_BATTERY: {
                    break;
                }
                default: {
                    break;
                }
            }
            break;
        }
        case FLOMIO_PING_OP: {
            NSInteger statusCode;
            switch (floMessage.subOpcodeLSN) {
                case FLOMIO_PONG:
                    statusCode = FLOMIO_STATUS_PING_RECIEVED;
                    break;
                case FLOMIO_PONG_LOW_POWER_ERROR:
                    statusCode = FLOMIO_STATUS_PING_LOW_POWER_ERROR;
                    break;
                case FLOMIO_PONG_CALIBRATION_ERROR:
                    statusCode = FLOMIO_STATUS_PING_CALIBRATION_ERROR;
                    break;
                default:
                    statusCode = FLOMIO_STATUS_PING_RECIEVED;
                    break;
            }
            
            if ([_delegate respondsToSelector:@selector(floReaderManager: didHaveStatus:)]) {
                [_delegate floReaderManager:self didHaveStatus:statusCode];
            }
            
            LogInfo(@"FLOMIO_PING_OP ");
            LogInfo(@"(TX) FLOMIO_PONG_OP ");
            FJMessage *pongMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_PING_OP
                                                                     andSubOpcode:FLOMIO_PONG
                                                                          andData:nil];
            [self sendMessageToHost:pongMessage];
            break;
        }
        case FLOMIO_ACK_ENABLE_OP:
            switch (floMessageSubOpcode) {
                case FLOMIO_ACK_BAD:
                    if ([_delegate respondsToSelector:@selector(floReaderManager: didHaveStatus:)]) {
                        NSInteger statusCode = FLOMIO_STATUS_NACK_ERROR;
                        [_delegate floReaderManager:self didHaveStatus:statusCode];
                    }
                    LogInfo(@"FLOMIO_ACK_BAD ");
                    LogInfo(@"(TX) resendLastMessageSent ");
                    NSLog(@"FLOMIO_ACK_BAD ");

                    [self resendLastMessageSent];
                    break;
                case FLOMIO_ACK_GOOD:
                    LogInfo(@"FLOMIO_ACK_GOOD ");
                    break;
                default:
                    break;
            }
            break;
        case FLOMIO_TAG_READ_OP: {
            LogInfo(@"(FLOMIO_TAG_READ_OP) Tag UID Received %@", [message fj_asHexString]);
            if (floMessage.subOpcodeLSN == FLOMIO_UID_ONLY) {
                // Tag UID Only
                NSLog(@"Tag UID Only");

                if ([_delegate respondsToSelector:@selector(floReaderManager: didScanTag:)]) {
                    FJNFCTag *tag = [[FJNFCTag alloc] initWithUid:[floMessage.data copy] andData:nil andType:floMessage.subOpcodeMSN];
                    [_delegate floReaderManager:self didScanTag:tag];
                }
            }
            else {
                // Tag all Memory
                int tagUidLen = 0;
                switch (floMessage.subOpcodeLSN) {
                    case FLOMIO_ALL_MEM_UID_LEN_FOUR:
                        tagUidLen = 4;
                        break;
                    case FLOMIO_ALL_MEM_UID_LEN_SEVEN:
                        tagUidLen = 7;
                        break;
                    case FLOMIO_ALL_MEM_UID_LEN_EIGHT:
                        tagUidLen = 8;
                        break;
                    case FLOMIO_ALL_MEM_UID_LEN_TEN:
                        tagUidLen = 10;
                        break;
                    default:
                        tagUidLen = 7;
                        break;
                }                
                NSRange tagUidRange = NSMakeRange(0, tagUidLen);
                NSData *tagUid = [[NSData alloc] initWithData:[floMessage.data subdataWithRange:tagUidRange]];
                NSLog(@"Tag w/ UID and Data - UID:: %@",tagUid);
//                if((floMessageLen - tagUidLen)>0)
//                {
//                    NSRange tagDataRange = NSMakeRange(tagUidLen,floMessageLen - tagUidLen);
//                    NSData *tagData = [[NSData alloc] initWithData:[floMessage.data subdataWithRange:tagDataRange]];
//                    NSLog(@"Tag w/ UID and Data - DATA:: %@",tagData);
//                }
               
                if ([_delegate respondsToSelector:@selector(floReaderManager: didScanTag:)]) {
                    FJNFCTag *tag = [[FJNFCTag alloc] initWithUid:tagUid andData:[floMessage.data copy] andType:floMessage.subOpcodeMSN];
                    [_delegate floReaderManager:self didScanTag:tag];
                }
            }
            break;
        }
        case FLOMIO_TAG_WRITE_OP: {
            LogInfo(@"%@", floMessage.name);
            if ([_delegate respondsToSelector:@selector(floReaderManager: didWriteTagAndStatusWas:)]) {
                NSInteger writeStatus = floMessage.subOpcode;
                [_delegate floReaderManager:self didWriteTagAndStatusWas:writeStatus];
            }
        }
        case FLOMIO_PROTO_ENABLE_OP: {
            break;
        }
        case FLOMIO_POLLING_ENABLE_OP: {
            // TODO Need to implement the response to delegate to notify app that Reader changed polling config
            break;
        }
        case FLOMIO_POLLING_RATE_OP: {
            break;
        }
        case FLOMIO_STANDALONE_OP: {
            // TODO Need to implement the response to delegate to notify app that Reader changed standalone mode
            break;
        }
        case FLOMIO_STANDALONE_TIMEOUT_OP: {
            break;
        }
        case FLOMIO_DUMP_LOG_OP: {
            break;
        }
    }
}


/**
 Resend the last transmitted message, typically used when NACK is returned.
 
 @return void
 */
- (void)resendLastMessageSent {
    [self sendMessageDataToHost:_lastMessageSent];
}

/**
 Send message to Reader.
 
 @param NSData  Byte representation of Reader command
 @return void
 */
- (void)sendMessageDataToHost:(NSData *)data {
    [self setLastMessageDataSent:data];
    [_nfcService sendMessageDataToHost:data];
}

/**
 Send message to Reader.
 
 @param FJMessage FJMessage representation of Reader command
 @return void
 */
- (void)sendMessageToHost:(FJMessage *)theMessage {
    [self setLastMessageDataSent:[theMessage.bytes copy]];
    [_nfcService sendMessageDataToHost:[theMessage.bytes copy]];
}

/**
 Send message to Reader.
 
 @param UInt8[]  Byte array representatino of Reader command.
 @return void
 */
- (void)sendRawMessageToHost:(UInt8[])theMessage {
    //TODO: shift over to OO method of message creation + sending
    [self sendMessageDataToHost:[[NSData alloc] initWithBytes:theMessage length:theMessage[FLO_MESSAGE_LENGTH_POSITION]]];
}

/**
 Enter Reader into read tag UID mode. When tags are discovered only the UID
 will be returned.
 
 @return void
 */
- (void)setModeReadTagUID {
    UInt8 redundantReads = 1;
    FJMessage *setModeMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_OPERATION_MODE_OP
                                                               andSubOpcode:FLOMIO_OP_MODE_READ_UID
                                                                    andData:[NSData dataWithBytes:&redundantReads length:1]];
    [self sendMessageDataToHost:setModeMessage.bytes];
}

/**
 Enter Reader into read tag UID + NDEF mode. When tags are discovered the UID
 and any NDEF encoded data will be returned.
 
 @return void
 */
- (void)setModeReadTagUIDAndNDEF {
    FJMessage *setModeMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_OPERATION_MODE_OP
                                                                andSubOpcode:FLOMIO_OP_MODE_READ_UID_NDEF
                                                                     andData:nil];
    [self sendMessageDataToHost:setModeMessage.bytes];
}

/**
 Enter Reader into read tag data mode. When tags are discovered the
 entire memory structure will be returned in cluding UID, OTP fields,
 capability counters, TLV, and other meta information.
 
 @return void
 */
- (void)setModeReadTagData {
    FJMessage *setModeMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_OPERATION_MODE_OP
                                                                andSubOpcode:FLOMIO_OP_MODE_READ_ALL_MEMORY
                                                                     andData:nil];
    [self sendMessageDataToHost:setModeMessage.bytes];
}

/**
 Transmit the current NDEF Message to the Reader and write it to next tag detected.
 
 @param NDEFMessage   NDEF Message for writing
 @return void
 */
- (void)setModeWriteTagWithNdefMessage:(NDEFMessage *)theNDEFMessage {
    
    NSData *ndefMessageData = theNDEFMessage.asByteBuffer;
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_OPERATION_MODE_OP
                                                                andSubOpcode:FLOMIO_OP_MODE_WRITE_CURRENT
                                                                     andData:ndefMessageData];
    NSLog(@"write FJMessage: %@", [floMessage.bytes fj_asHexString]);
    [self sendMessageDataToHost:[floMessage.bytes copy]];
    
    int i =0;
    i++;
}

/**
 Enter the Reader into write mode and rewrite the last NDEFMessage from cache.
 
 @return void
 */
- (void)setModeWriteTagWithPreviousNdefMessage; {
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_OPERATION_MODE_OP
                                                                andSubOpcode:FLOMIO_OP_MODE_WRITE_PREVIOUS
                                                                     andData:nil];
    NSLog(@"write FJMessage: %@", [floMessage.bytes fj_asHexString]);
    [self sendMessageDataToHost:floMessage.bytes];
}

/**
 Keeps track of the last message sent to the device. Useful for keeping state until ACK / NACK received.
 
 @param NSData message
 @return void
 */
- (void)setLastMessageDataSent:(NSData *)message {
    [_lastMessageSent setData:message];
}

/*
 Enable or disable polling for a given NFC RF protocol.
 
 @param BOOL  Enable or disable polling
 @param flomio_proto_opcodes_t  Selected protocol (14443A/B, 15693, Felica)
 @return void
 */
- (void)setPolling:(BOOL)enablePolling forProtocol:(flomio_proto_opcodes_t)protocol {
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_PROTO_ENABLE_OP
                                                                andSubOpcode:protocol
                                                                     andData:[NSData dataWithBytes:&enablePolling length:1]];
    [self sendMessageDataToHost:floMessage.bytes];
}

/*
 Enable or disable polling for 14443A tags.
 
 @param BOOL  14443A polling enabled
 @return void
 */
- (void)setPollFor14443aTags:(BOOL)enablePolling {
    _pollFor14443aTags = enablePolling;
    [self setPolling:(BOOL)enablePolling forProtocol:FLOMIO_PROTO_14443A];
}

/*
 Enable or disable polling for 15693 vicinity tags.
 
 @param BOOL  15693 polling enabled
 @return void
 */
- (void)setPollFor15693Tags:(BOOL)enablePolling {
    _pollFor15693Tags = enablePolling;
    [self setPolling:(BOOL)enablePolling forProtocol:FLOMIO_PROTO_15693];
}

/*
 Enable or disable polling for Sony Felica tags.
 
 @param BOOL  Felica polling enabled
 @return void
 */
- (void)setPollForFelicaTags:(BOOL)enablePolling {
    _pollForFelicaTags = enablePolling;
    [self setPolling:(BOOL)enablePolling forProtocol:FLOMIO_PROTO_FELICA];
}

/*
 Enable or disable Reader standalone mode.  This keeps Reader from going to sleep
 after disconnecting from Host device.  Reader will continue to scan tags very much
 like the Poken devices.
 
 @param BOOL  Standalone mode enable
 @return void
 */
- (void)setStandaloneMode:(BOOL)standaloneMode {
    _standaloneMode = standaloneMode;
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_STANDALONE_OP
                                                                andSubOpcode:_standaloneMode
                                                                andData:nil];
    [self sendMessageDataToHost:floMessage.bytes];
}

/*
 Set the tag polling rate in milliseconds. Acceptable rates are [0, 6375] in 25ms increments.
 
 @param pollPeriod The polling period (should be in range [0, 6375] and a multiple of 25]
 @return void
 */
- (void)setPollPeriod:(NSInteger)pollPeriod {
    if (pollPeriod < 0) {
        pollPeriod = 0;
    }
    else if(pollPeriod > 6375) {
        pollPeriod = 6375;        
    }
    
    // Resolution is 25ms increments
    pollPeriod -= (pollPeriod % 25);    
    _pollPeriod = pollPeriod;
    
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_POLLING_RATE_OP
                                                                andSubOpcode:(pollPeriod / 25)
                                                                     andData:nil];
    [self sendMessageDataToHost:floMessage.bytes];
}

/* 
 Increment the Sniffer Threshold by a specified number of steps.  Acceptable range is [0, 65536].
 Protection against Threshold overrun is left to the Reader firmware to protect against.
 
 @param incrementAmount The amount by which to increment Sniffer THreshold
 @return void
*/
- (void)setIncrementSnifferThreshold:(UInt16)incrementAmount {
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_SNIFFER_CONFIG_OP
                                                                andSubOpcode:FLOMIO_INCREMENT_THRESHOLD
                                                                     andData:[NSData dataWithBytes:&incrementAmount length:2]];
    [self sendMessageDataToHost:floMessage.bytes];
}

/*
 Decrement the Sniffer Threshold by a specified number of steps.  Acceptable range is [0, 65536].
 Protection against Threshold negtive swing is left to the Reader firmware to protect against.
 
 @param incrementAmount The amount by which to increment Sniffer THreshold
 @return void
 */
- (void)setDecrementSnifferThreshold:(UInt16)decrementAmount {
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_SNIFFER_CONFIG_OP
                                                                andSubOpcode:FLOMIO_DECREMENT_THRESHOLD
                                                                     andData:[NSData dataWithBytes:&decrementAmount length:2]];
    [self sendMessageDataToHost:floMessage.bytes];
}

/*
 Force a full re-calibration process to reset the Sniffer Threshold.  This command doesn't take 
 any arguments or expects any return response.
 
 @return void
 */
- (void)sendResetSnifferThreshold {
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_SNIFFER_CONFIG_OP
                                                                andSubOpcode:FLOMIO_RESET_THRESHOLD
                                                                     andData:nil];
    [self sendMessageDataToHost:floMessage.bytes];
}

/*
 Set the max value of the Sniffer Threshold to a specified number.  Acceptable range is [0, 65536].
 The lower the value the more reactive the Sniffer routine will react to false positive.
 
 @param maxThreshold The amount by which to increment Sniffer THreshold
 @return void
 */
- (void)setMaxSnifferThreshold:(UInt16)maxThreshold {
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_SNIFFER_CONFIG_OP
                                                                andSubOpcode:FLOMIO_SET_MAX_THRESHOLD
                                                                     andData:[NSData dataWithBytes:&maxThreshold length:2]];
    [self sendMessageDataToHost:floMessage.bytes];
}

/*
 Set the LED mode (manually).  Acceptable range is defined in typedef led_status_t.
 @return void
 */
- (void)setLedMode:(UInt16)ledMode
{
    FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_LED_CONTROL_OP
                                                                andSubOpcode:(unsigned char)ledMode
                                                                     andData:nil];
    [self sendMessageDataToHost:floMessage.bytes];
}

/**
 Send command for floBLE to disconnect.
 
 @return void
 */
- (void)disconnectDevice
{
     FJMessage *floMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_DISCONNECT_OP
     andSubOpcode:0
     andData:nil];
     [self sendMessageDataToHost:floMessage.bytes];
    

    if([self->_nfcService activePeripheral])
    {
        [self->_nfcService disconnectPeripheral:[self->_nfcService activePeripheral]];
    }
    NSLog(@"disconnectPeripheral:activePeripheral");
}

#pragma mark - NFC Service Delegate

/**
 Receives decoded messages from the FLOReader.
 
 @param nfcService      The NFC Service Object experiencing an error.
 @param theMessage      The received message.
 @return void
 */
- (void)nfcService:(FLOReader *)nfcService didReceiveMessage:(NSData *)theMessage; {
    if(theMessage != nil || theMessage.length > 0) {
        [self parseMessage:theMessage];
        NSLog(@"nfcService received message %@",theMessage);
    }
}

/**
 Receives error codes from the NFC Service (e.g. corrupt message, message timeout, etc) and passes 
 them up to the NFC Adapter delegate. Suggested that third party apps surface these to the user
 in a meaningful way. 
 
 @param nfcService      The NFC Service Object experiencing an error.
 @param errorCode       The error code experienced by the NFC Service.
 @return void
 */
- (void)nfcService:(FLOReader *)nfcService didHaveError:(NSInteger)errorCode {
    switch (errorCode) {      
        case FLOMIO_STATUS_VOLUME_LOW_ERROR:
        case FLOMIO_STATUS_MESSAGE_CORRUPT_ERROR:
        case FLOMIO_STATUS_NACK_ERROR:
        case FLOMIO_STATUS_GENERIC_ERROR:
        case FLOMIO_STATUS_READER_DISCONNECTED:
            LogError("%@", [FJMessage formatStatusCodesToString:(flomio_nfc_adapter_status_codes_t)errorCode]);
            break;
        default:
            LogInfo("%@", [FJMessage formatStatusCodesToString:(flomio_nfc_adapter_status_codes_t)errorCode]);
            break;
    }    
    if ([_delegate respondsToSelector:@selector(floReaderManager: didHaveStatus:)]) {
        [_delegate floReaderManager:self didHaveStatus:errorCode];
    }
}


@end
