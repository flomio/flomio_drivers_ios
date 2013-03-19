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
        [_nfcService checkVolumeLevel];
        
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
                if ([_delegate respondsToSelector:@selector(nfcAdapter: didHaveStatus:)]) {
                    NSInteger statusCode = FLOMIO_STATUS_PING_RECIEVED;
                    [_delegate nfcAdapter:self didHaveStatus:statusCode];
                }
                
                LogInfo(@"FLOMIO_PING_OP ");
                LogInfo(@"(TX) FLOMIO_PONG_OP ");
                [self sendMessageToHost:(UInt8*)pong_command];
                break;
            }
            case FLOMIO_ACK_ENABLE_OP:
                switch (flojackMessageSubOpcode) {
                    case FLOMIO_ACK_BAD:
                        if ([_delegate respondsToSelector:@selector(nfcAdapter: didHaveStatus:)]) {
                            NSInteger statusCode = FLOMIO_STATUS_NACK_ERROR;
                            [_delegate nfcAdapter:self didHaveStatus:statusCode];
                        }
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
            case FLOMIO_TAG_READ_OP: {
                LogInfo(@"(FLOMIO_TAG_READ_OP) Tag UID Received %@", [message fj_asHexString]);

                if (messyTest.subOpcodeLSN == FLOMIO_UID_ONLY) {
                    // Tag UID Only
                    if ([_delegate respondsToSelector:@selector(nfcAdapter: didScanTag:)]) {
                        FJNFCTag *tag = [[FJNFCTag alloc] initWithUid:[messyTest.data copy] andData:nil andType:messyTest.subOpcodeMSN];
                        [_delegate nfcAdapter:self didScanTag:tag];
                    }
                }
                else {
                    // Tag all Memory
                    int tagUidLen = 0;
                    switch (messyTest.subOpcodeLSN) {
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
                        FJNFCTag *tag = [[FJNFCTag alloc] initWithUid:tagUid andData:[messyTest.data copy] andType:messyTest.subOpcodeMSN];
                        [_delegate nfcAdapter:self didScanTag:tag];
                    }
                }                
                break;
            }
            case FLOMIO_TAG_WRITE_OP: {
                LogInfo(@"%@", messyTest.name);
                if ([_delegate respondsToSelector:@selector(nfcAdapter: didWriteTagAndStatusWas:)]) {
                    NSInteger writeStatus = messyTest.subOpcode;
                    [_delegate nfcAdapter:self didWriteTagAndStatusWas:writeStatus];
                }
            }
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

- (void)operationModeWriteDataTestPrevious {
    UInt8 bytes[] = {FLOMIO_OPERATION_MODE_OP, 0x04, FLOMIO_OP_MODE_WRITE_PREVIOUS, 0x09};
    [self sendMessageToHost:(UInt8 *)bytes];
}

// Check if FloJack NFC reader is plugged in
- (BOOL) isFloJackPluggedIn {
    return [_nfcService isHeadsetPluggedIn];
}

/**
 Transmit the current NDEF Message to the FloJack and write it to next tag detected.
 
 @param FJNDEFMessage   NDEF Message for writing
 
 @return void
 */
- (void)writeTagWithNdefMessage:(FJNDEFMessage *)theNDEFMessage {
    
    NSData *ndefMessageData = theNDEFMessage.asByteBuffer;
    FJMessage *flojackMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_OPERATION_MODE_OP
                                                                andSubOpcode:FLOMIO_OP_MODE_WRITE_CURRENT
                                                                     andData:ndefMessageData];
    NSLog(@"write FJMessage: %@", [flojackMessage.bytes fj_asHexString]);
    [self sendMessageDataToHost:flojackMessage.bytes];
}

/**
 Enter the FloJack into write mode and rewrite the last NDEFMessage from cache.
 
 @return void
 */
- (void)writeTagWithPreviousNdefMessage; {
    FJMessage *flojackMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_OPERATION_MODE_OP
                                                                andSubOpcode:FLOMIO_OP_MODE_WRITE_PREVIOUS
                                                                     andData:nil];
    NSLog(@"write FJMessage: %@", [flojackMessage.bytes fj_asHexString]);
    [self sendMessageDataToHost:flojackMessage.bytes];
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
    
    // pause to let line settle
    [NSThread sleepForTimeInterval:.100];
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

- (void)sendMessageDataToHost:(NSData *)data  {
    [self setLastMessageSent:(UInt8 *)data.bytes];
    [_nfcService sendMessageToHost:(UInt8 *)data.bytes];
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

/**
 Receives error codes from the NFC Service (e.g. corrupt message, message timeout, etc) and passes 
 them up to the NFC Adapter delegate. Suggested that third party apps surface these to the user
 in a meaningful way. 
 
 @param nfcService      The NFC Service Object experiencing an error.
 @param errorCode       The error code experienced by the NFC Service.
 @return void
 */
- (void)nfcService:(FJNFCService *)nfcService didHaveError:(NSInteger)errorCode {
    if ([_delegate respondsToSelector:@selector(nfcAdapter: didHaveStatus:)]) {
        [_delegate nfcAdapter:self didHaveStatus:errorCode];
    }    
}

- (void)nfcServiceDidReceiveFloJack:(FJNFCService *)nfcService connectedStatus:(BOOL)isFloJackConnected; {
    if (isFloJackConnected) {
        // Send interbyte delay config message based on iOS device type
        UInt8 interByteDelay = [FJNFCService getDeviceInterByteDelay];
        FJMessage *configMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_COMMUNICATION_CONFIG_OP
                                                                   andSubOpcode:FLOMIO_BYTE_DELAY
                                                                        andData:[NSData dataWithBytes:&interByteDelay length:1]];
        [self sendMessageDataToHost:configMessage.bytes];
    }
    
    if (isFloJackConnected && [_delegate respondsToSelector:@selector(nfcAdapterDidDetectFloJackConnected:)]) {
        [_delegate nfcAdapterDidDetectFloJackConnected:self];
    } else if ([_delegate respondsToSelector:@selector(nfcAdapterDidDetectFloJackDisconnected:)]) {
        [_delegate nfcAdapterDidDetectFloJackDisconnected:self];
    }    
}

@end
