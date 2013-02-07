//
//  FJNFCAdapter.m
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FJNFCAdapter.h"

#define HIGHJACK_SENDBYTE(x) while ([_nfcService send:x])

@implementation FJNFCAdapter {
    id <FJNFCAdapterDelegate>       _delegate;
    FJNFCService                    *_nfcService;
    NSMutableData                   *_lastMessageSent;
}

@synthesize delegate = _delegate;

- (id) init {
    self = [super init];
    if (self) {
        _nfcService = [[FJNFCService alloc] init];
        [_nfcService setDelegate:self];
        
        _lastMessageSent = [[NSMutableData alloc] initWithCapacity:MAX_MESSAGE_LENGTH];
        
    }      
    return self;    
}

- (void) setDelegate:(id <FJNFCAdapterDelegate>) delegate {
	_delegate = delegate;
}


-(void) parseMessage:(NSData *)message;
{

//    LogInfo(@"parseMessage: %@", [message fj_asHexString]);

//    UInt8 flojackMessageOpcode = 0;
//    [message getBytes:&flojackMessageOpcode range:NSMakeRange(FLOJACK_MESSAGE_OPCODE_POSITION,
//                                                              FLOJACK_MESSAGE_OPCODE_LENGTH)];
//    UInt8 flojackMessageSubOpcode = 0;
//    [message getBytes:&flojackMessageSubOpcode range:NSMakeRange(FLOJACK_MESSAGE_SUB_OPCODE_POSITION,
//                                                                 FLOJACK_MESSAGE_SUB_OPCODE_LENGTH)];
//    UInt8 flojackMessageEnable = 0;
//    [message getBytes:&flojackMessageEnable range:NSMakeRange(FLOJACK_MESSAGE_ENABLE_POSITION,
//                                                                 FLOJACK_MESSAGE_ENABLE_LENGTH)];
    
        FJMessage *messyTest = [[FJMessage alloc] initWithData:message];
        UInt8 flojackMessageOpcode = messyTest.opcode;
        UInt8 flojackMessageSubOpcode = messyTest.subOpcode;
        UInt8 flojackMessageEnable = messyTest.enable;
        NSData *messageData = [messyTest.data copy];
    
    
        //check opcode
        switch (flojackMessageOpcode) {
            case FLOMIO_STATUS_OP:
                switch (flojackMessageSubOpcode)
                {
                    case FLOMIO_STATUS_ALL:
                        break;
                    case FLOMIO_STATUS_HW_REV: {
                        LogInfo(@"FLOMIO_STATUS_HW_REV ");
                        NSString *hardwareVersion = [NSString stringWithFormat:@"%@", [messageData fj_asHexString]];
                        
                        if ([_delegate respondsToSelector:@selector(nfcAdapter: didReceiveHardwareVersion:)]) {
                            [_delegate nfcAdapter:self didReceiveHardwareVersion:hardwareVersion];
                        }
                    }
                        break;
                    case FLOMIO_STATUS_SW_REV: {
                        LogInfo(@"FLOMIO_STATUS_SW_REV ");
                        NSString *firmwareVersion = [NSString stringWithFormat:@"%@", [messageData fj_asHexString]];
                        
                        if ([_delegate respondsToSelector:@selector(nfcAdapter: didReceiveFirmwareVersion:)]) {
                            [_delegate nfcAdapter:self didReceiveFirmwareVersion:firmwareVersion];
                        }
                    }
                        break;
                    case FLOMIO_STATUS_BATTERY:    //not currently supported
                        //break; //intentional fall through
                    default:
                        //not currently supported
                        break;
                }
                break;
            case FLOMIO_PROTO_ENABLE_OP:
                    switch (flojackMessageSubOpcode) {
                        case FLOMIO_PROTO_14443A:
                            switch (flojackMessageEnable) {
                                case FLOMIO_ENABLE:
                                    break;
                                case FLOMIO_DISABLE:
                                    break;
                            }
                            break;
                        case FLOMIO_PROTO_14443B:
                            switch (flojackMessageEnable) {
                                case FLOMIO_ENABLE:
                                    break;
                                case FLOMIO_DISABLE:
                                    break;
                            }
                            break;
                        case FLOMIO_PROTO_15693:
                            switch (flojackMessageEnable) {
                                case FLOMIO_ENABLE:
                                    break;
                                case FLOMIO_DISABLE:
                                    break;
                            }
                            break;
                        case FLOMIO_PORTO_FELICA:
                            switch (flojackMessageEnable) {
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
                switch (flojackMessageEnable) {
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
            case FLOMIO_PING_OP:
            {
                LogInfo(@"FLOMIO_PING_OP ");
                LogInfo(@"(TX) FLOMIO_PONG_OP ");
                [self sendMessageToHost:(UInt8*)pong_command];
                break;
            }
            case FLOMIO_ACK_ENABLE_OP:
                switch (flojackMessageSubOpcode) {
                    case FLOMIO_ACK_BAD:
                        LogInfo(@"FLOMIO_ACK_BAD ");
                        LogInfo(@"(TX) resendLastMessageSent ");
                        [self resendLastMessageSent];
                        break;
                    case FLOMIO_ACK_GOOD:
                        LogInfo(@"FLOMIO_ACK_GOOD ");
                        break;
                    case FLOMIO_DISABLE:
                        break;
                    case FLOMIO_ENABLE:
                        break;
                    default:
                        break;
                }
                break;
            case FLOMIO_STANDALONE_OP:
                switch (flojackMessageEnable) {
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
                    switch (flojackMessageSubOpcode) {
                        case FLOMIO_LOG_ALL:
                            break;
                        default:
                            //not currently supported
                            break;
                    }
                break;
            case FLOMIO_TAG_UID_OP: {
                LogInfo(@"(FLOMIO_TAG_UID_OP) Tag UID Received %@", [message fj_asHexString]);

                if (flojackMessageSubOpcode == FLOMIO_UID_ONLY) {
                    // Tag UID Only
                    if ([_delegate respondsToSelector:@selector(nfcAdapter: didScanTag:)]) {
                        FJNFCTag *tag = [[FJNFCTag alloc] initWithUid:[messyTest.data copy]];
                        [_delegate nfcAdapter:self didScanTag:tag];
                    }
                }
                else {
                    // Tag all Memory
                    int tagUidLen = 0;
                    int tagDataLen = 0;
                    switch (flojackMessageSubOpcode) {
                        case FLOMIO_ALL_MEM_UID_LEN_FOUR:
                            tagUidLen = 4;
                            break;
                        case FLOMIO_ALL_MEM_UID_LEN_SEVEN:
                            tagUidLen = 7;
                            break;
                        case FLOMIO_ALL_MEM_UID_LEN_TEN:
                            tagUidLen = 10;
                            break;
                        default:
                            tagUidLen = 7;
                            break;
                    }
                    
                    NSRange tagUidRange = NSMakeRange(0, tagUidLen);
                    NSData *tagUid = [[NSData alloc] initWithData:[messyTest.data subdataWithRange:tagUidRange]];
                    
                    if ([_delegate respondsToSelector:@selector(nfcAdapter: didScanTag:)]) {
                        FJNFCTag *tag = [[FJNFCTag alloc] initWithUid:tagUid andData:[messyTest.data copy]];
                        [_delegate nfcAdapter:self didScanTag:tag];
                    }
                }                
                break;
            }
//            case FLOMIO_LED_CONTROL_OP:   //not currently supported
//            default:
//                //not currently supported
//                break;
        }    
}

// Turn off 14443A Protocol
- (void)disable14443AProtocol {
    [self sendMessageToHost:(UInt8*)protocol_14443A_off_msg];
}

// Turn off 14443B Protocol
- (void)disable14443BProtocol {
    [self sendMessageToHost:(UInt8*)protocol_14443B_off_msg];
}

// Turn off 15693 Protocol
- (void)disable15693Protocol {
    [self sendMessageToHost:(UInt8*)protocol_15693_off_msg];
}

// Turn off Ack/Nack
- (void)disableMessageAcks {
    [self sendMessageToHost:(UInt8*)ack_disable_msg];
}

// Turn off Felica Protocol
- (void)disableFelicaProtocol {
    [self sendMessageToHost:(UInt8*)protocol_felica_off_msg];
}

// Turn off Standalone Mode
- (void)disableStandaloneMode {
    [self sendMessageToHost:(UInt8*)standalone_disable_msg];
}

// Turn off Tag polling
- (void)disableTagPolling {
    [self sendMessageToHost:(UInt8*)polling_disable_msg];
}

// Dump and Clear out tag log
- (void)dumpAndClearTagLog {
    [self sendMessageToHost:(UInt8*)dump_log_all_msg];
}

// Get NFC accessory hardware version
- (void)getAllStatus {
    [self sendMessageToHost:(UInt8*)status_msg];
}

/**
 Returns the current FloJack firmware version. Useful for diagnostic as well as checks being performed before firmware updates.
 
 @return none
 */
- (void)getFirmwareVersion {
    [self sendMessageToHost:(UInt8*)status_sw_rev_msg];
}

// Get NFC accessory hardware version
- (void)getHardwareVersion {
    [self sendMessageToHost:(UInt8*)status_hw_rev_msg];
}

// Turn on 14443A Protocol
- (void)enable14443AProtocol {
    [self sendMessageToHost:(UInt8*)protocol_14443A_msg];
}

// Turn on 14443B Protocol
- (void)enable14443BProtocol {
    [self sendMessageToHost:(UInt8*)protocol_14443B_msg];
}

// Turn on 15693 Protocol
- (void)enable15693Protocol {
    [self sendMessageToHost:(UInt8*)protocol_15693_msg];
}

// Turn on Felica Protocol
- (void)enableFelicaProtocol {
    [self sendMessageToHost:(UInt8*)protocol_felica_msg];
}

// Turn on message Ack/Nack
- (void)enableMessageAcks {
    [self sendMessageToHost:(UInt8*)ack_enable_msg];
}

// Turn on Tag polling
- (void)enableTagPolling {
    [self sendMessageToHost:(UInt8*)polling_enable_msg];
}

// Turn on Standalone Mode
- (void)enableStandaloneMode {
    [self sendMessageToHost:(UInt8*)standalone_enable_msg];
}

// Set polling rate to 1000ms
- (void)setPollingRateTo1000ms {
    [self sendMessageToHost:(UInt8*)polling_frequency_1000ms_msg];
}

// Set polling rate to 3000ms
- (void)setPollingRateTo3000ms {
    [self sendMessageToHost:(UInt8*)polling_frequency_3000ms_msg];
}

// Set Standalone Mode KAT to 1 minute
- (void)setStandaloneModeKeepAliveTimeToOneMinute {
    [self sendMessageToHost:(UInt8*)keep_alive_time_one_min_msg];
}

// Set standalone mode KAT to infinite
- (void)setStandaloneModeKeepAliveTimeInfinite {
    [self sendMessageToHost:(UInt8*)keep_alive_time_infinite_msg];
}

// Turn the LED on
- (void)turnLedOn {
    [self sendMessageToHost:(UInt8*)ti_host_command_led_on_msg];
}

// Turn the LED off
- (void)turnLedOff {
    [self sendMessageToHost:(UInt8*)ti_host_command_led_off_msg];
}

- (void)operationModeUID {
    [self sendMessageToHost:(UInt8 *)op_mode_uid_only];
}

- (void)operationModeReadOnly {
    [self sendMessageToHost:(UInt8 *)op_mode_read_memory_only];
}


// Check if FloJack NFC reader is plugged in
- (BOOL) isFloJackPluggedIn {
    return [_nfcService isHeadsetPluggedIn];
}

/**
 resendLastMessageSent()
 Resend the last transmitted message, typically used when NACK is returned.
 
 @return void
 */
- (void)resendLastMessageSent {
    unsigned char *message = (unsigned char *)[_lastMessageSent bytes];
    UInt8 messageLength = 0;
    [_lastMessageSent getBytes:&messageLength
                              range:NSMakeRange(FLOJACK_MESSAGE_LENGTH_POSITION,
                                                FLOJACK_MESSAGE_LENGTH_POSITION)];
    [_nfcService sendMessageToHost:message withLength:messageLength];
}

/**
 setLastMessageSent()
 Keeps track of the last message sent to the device. Useful for keeping state until ACK / NACK received.
 
 @return void
 */
- (void)setLastMessageSent:(UInt8[])message {
    int messageLength = message[FLOJACK_MESSAGE_LENGTH_POSITION];
    [_lastMessageSent setLength:messageLength];
    [_lastMessageSent replaceBytesInRange:NSMakeRange(0, messageLength)
                                withBytes:message];
}

- (void)sendMessageToHost:(UInt8[])message  {
    // TODO, reimplement this with NSData 
    [self setLastMessageSent:message];
    [_nfcService sendMessageToHost:message];
}

- (void)sendMessageToHost:(UInt8[])message withSizeOf:(int)msgSize {
    [self setLastMessageSent:message];
    [_nfcService sendMessageToHost:message withLength:(int)msgSize];
}

- (void)dealloc {
    [super dealloc];
}


#pragma mark - NFC Service Delegate

- (void)nfcService:(FJNFCService *)nfcService didReceiveMessage:(NSData *)theMessage; {
    if(theMessage != nil || theMessage.length > 0) {
        [self parseMessage:theMessage];
    }
}

- (void)nfcServiceDidReceiveFloJack:(FJNFCService *)nfcService connectedStatus:(BOOL)isFloJackConnected; {
    if (isFloJackConnected) {
        // Set interbyte delay based on iOS device type
        [self sendMessageToHost:[_nfcService getCommunicationConfigMessage]];
    }
    
    if (isFloJackConnected && [_delegate respondsToSelector:@selector(nfcAdapterDidDetectFloJackConnected:)]) {
        [_delegate nfcAdapterDidDetectFloJackConnected:self];
    } else if ([_delegate respondsToSelector:@selector(nfcAdapterDidDetectFloJackDisconnected:)]) {
        [_delegate nfcAdapterDidDetectFloJackDisconnected:self];
    }    
}

@end
