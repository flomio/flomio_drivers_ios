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
@synthesize deviceHasVolumeCap = _deviceHasVolumeCap;
@synthesize pollFor14443aTags = _pollFor14443aTags;
@synthesize pollFor15693Tags = _pollFor15693Tags;
@synthesize pollForFelicaTags = _pollForFelicaTags;

- (id) init {
    self = [super init];
    if (self) {
        _nfcService = [[FJNFCService alloc] init];
        [_nfcService setDelegate:self];
        [_nfcService checkIfVolumeLevelMaxAndNotifyDelegate];
        
        _lastMessageSent = [[NSMutableData alloc] initWithCapacity:MAX_MESSAGE_LENGTH];
        _deviceHasVolumeCap = false;
        _pollFor14443aTags =  true;
        _pollFor15693Tags =  false;
        _pollForFelicaTags =  false;
    }      
    return self;    
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
                        case FLOMIO_PROTO_FELICA:
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
                // {0x0D, 0x04, 0x01, 0x08};
                FJMessage *pongMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_PING_OP
                                                                         andSubOpcode:FLOMIO_PONG
                                                                              andData:nil];
                [self sendMessageToHost:pongMessage];
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
    [self sendRawMessageToHost:(UInt8*)protocol_14443A_off_msg];
}

// Turn off 15693 Protocol
- (void)disable15693Protocol {
    [self sendRawMessageToHost:(UInt8*)protocol_15693_off_msg];
}

// Turn off Felica Protocol
- (void)disableFelicaProtocol {
    [self sendRawMessageToHost:(UInt8*)protocol_felica_off_msg];
}

// Get NFC accessory hardware version
- (void)getAllStatus {
    [self sendRawMessageToHost:(UInt8*)status_msg];
}

// Get FloJack Firmware version
- (void)getFirmwareVersion {
    [self sendRawMessageToHost:(UInt8*)status_sw_rev_msg];
}

// Get NFC accessory hardware version
- (void)getHardwareVersion {
    [self sendRawMessageToHost:(UInt8*)status_hw_rev_msg];
}

// Turn on 14443A Protocol
- (void)enable14443AProtocol {
    [self sendRawMessageToHost:(UInt8*)protocol_14443A_msg];
}

// Turn on 15693 Protocol
- (void)enable15693Protocol {
    [self sendRawMessageToHost:(UInt8*)protocol_15693_msg];
}

// Turn on Felica Protocol
- (void)enableFelicaProtocol {
    [self sendRawMessageToHost:(UInt8*)protocol_felica_msg];
}

// Set polling rate to 1000ms
- (void)setPollingRateTo1000ms {
    [self sendRawMessageToHost:(UInt8*)polling_frequency_1000ms_msg];
}

// Set polling rate to 3000ms
- (void)setPollingRateTo3000ms {
    [self sendRawMessageToHost:(UInt8*)polling_frequency_3000ms_msg];
}

- (void)operationModeWriteDataTestPrevious {
    UInt8 bytes[] = {FLOMIO_OPERATION_MODE_OP, 0x04, FLOMIO_OP_MODE_WRITE_PREVIOUS, 0x09};
    [self sendRawMessageToHost:(UInt8 *)bytes];
}

// Check if FloJack NFC reader is plugged in
- (BOOL) isFloJackPluggedIn {
    return [_nfcService isHeadsetPluggedIn];
}

/**
 TODO
 
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
 TODO
 
 @return void
 */
- (void)setModeReadTagData {
    FJMessage *setModeMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_OPERATION_MODE_OP
                                                                andSubOpcode:FLOMIO_OP_MODE_READ_ALL_MEMORY
                                                                     andData:nil];
    [self sendMessageDataToHost:setModeMessage.bytes];
}

/**
 Transmit the current NDEF Message to the FloJack and write it to next tag detected.
 
 @param FJNDEFMessage   NDEF Message for writing
 
 @return void
 */
- (void)setModeWriteTagWithNdefMessage:(FJNDEFMessage *)theNDEFMessage {
    
    NSData *ndefMessageData = theNDEFMessage.asByteBuffer;
    FJMessage *flojackMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_OPERATION_MODE_OP
                                                                andSubOpcode:FLOMIO_OP_MODE_WRITE_CURRENT
                                                                     andData:ndefMessageData];
    NSLog(@"write FJMessage: %@", [flojackMessage.bytes fj_asHexString]);
    [self sendMessageDataToHost:[flojackMessage.bytes copy]];
    
    int i =0;
    i++;
}

/**
 Enter the FloJack into write mode and rewrite the last NDEFMessage from cache.
 
 @return void
 */
- (void)setModeWriteTagWithPreviousNdefMessage; {
    FJMessage *flojackMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_OPERATION_MODE_OP
                                                                andSubOpcode:FLOMIO_OP_MODE_WRITE_PREVIOUS
                                                                     andData:nil];
    NSLog(@"write FJMessage: %@", [flojackMessage.bytes fj_asHexString]);
    [self sendMessageDataToHost:flojackMessage.bytes];
}

/**
 Resend the last transmitted message, typically used when NACK is returned.
 
 @return void
 */
- (void)resendLastMessageSent {
    [self sendMessageDataToHost:_lastMessageSent];    
}

/**
 TODO
 
 @param TODO
 @return void
 */
- (void)sendMessageDataToHost:(NSData *)data  {
    [self setLastMessageDataSent:data];
    [_nfcService sendMessageDataToHost:data];
}

/**
 TODO
 
 @param TODO
 @return void
 */
- (void)sendMessageToHost:(FJMessage *)theMessage  {
    [self setLastMessageDataSent:[theMessage.bytes copy]];
    [_nfcService sendMessageDataToHost:[theMessage.bytes copy]];
}

/**
 TODO
 
 @param TODO
 @return void
 */
- (void)sendRawMessageToHost:(UInt8[])theMessage  {
    //TODO: shift over to OO method of message creation + sending
    [self sendMessageDataToHost:[[NSData alloc] initWithBytes:theMessage length:theMessage[FLOJACK_MESSAGE_LENGTH_POSITION]]];
}

/*
 Send FloJack Wake + Config command to come out of deep sleep and begin polling.
 Also sets the inter-byte delay config value based on the device type.
 
 @return void
 */
- (void)initializeFloJackDevice {
    UInt8 interByteDelay = [FJNFCService getDeviceInterByteDelay];
    FJMessage *configMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_COMMUNICATION_CONFIG_OP
                                                               andSubOpcode:FLOMIO_BYTE_DELAY
                                                                    andData:[NSData dataWithBytes:&interByteDelay length:1]];
    [self sendMessageDataToHost:configMessage.bytes];
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
 Used to increase the output volume level for audio capped evices and resend config message.
 This is necessary for EU devices with audio caps at ~80dBA.
 The method first checks to see if the volume level is max before proceeding.
 
 WARNING:   IMPROPER USE CAN DAMAGE THE FLOJACK DEVICE.
 DO NOT USE ON NON AUDIO CAPPED DEVICES.
 
 @return void   
 */
- (void)setDeviceHasVolumeCap:(BOOL)deviceHasVolumeCap {
    _deviceHasVolumeCap = deviceHasVolumeCap;
    if (deviceHasVolumeCap) {
        [_nfcService setOutputAmplitudeHigh];
    }
    else {
        [_nfcService setOutputAmplitudeNormal];
    }
}

/*
 TODO
 
 @return void
 */
- (void)setPolling:(BOOL)enablePolling forProtocol:(flomio_proto_opcodes_t)protocol {
    FJMessage *flojackMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_PROTO_ENABLE_OP
                                                                andSubOpcode:protocol
                                                                     andData:[NSData dataWithBytes:&enablePolling length:1]];
    [self sendMessageDataToHost:flojackMessage.bytes];
}

/*
 TODO
 
 @return void
 */
- (void)setPollFor14443aTags:(BOOL)enablePolling {
    _pollFor14443aTags = enablePolling;
    [self setPolling:(BOOL)enablePolling forProtocol:FLOMIO_PROTO_14443A];
}

/*
 TODO
 
 @return void
 */
- (void)setPollFor15693Tags:(BOOL)enablePolling {
    _pollFor15693Tags = enablePolling;
    [self setPolling:(BOOL)enablePolling forProtocol:FLOMIO_PROTO_15693];
}

/*
 TODO
 
 @return void
 */
- (void)setPollForFelicaTags:(BOOL)enablePolling {
    _pollForFelicaTags = enablePolling;
    [self setPolling:(BOOL)enablePolling forProtocol:FLOMIO_PROTO_FELICA];
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

/**
 Receives connect / disconnect notifications from NFC Service, sends the wake + config message if needed, and passes the connection status up to the NFC Adapter delgate. 
 
 @param nfcService          The NFC Service Object experiencing an error.
 @param isFloJackConnected  Bool indicating FloJack connection status
 @return void
 */
- (void)nfcServiceDidReceiveFloJack:(FJNFCService *)nfcService connectedStatus:(BOOL)isFloJackConnected; {
    NSInteger statusCode;
    if (isFloJackConnected) {
        statusCode = FLOMIO_STATUS_FLOJACK_CONNECTED;
        [self initializeFloJackDevice];
    }
    else {
        statusCode = FLOMIO_STATUS_FLOJACK_DISCONNECTED;
    }
    
    if ([_delegate respondsToSelector:@selector(nfcAdapter: didHaveStatus:)]) {
        [_delegate nfcAdapter:self didHaveStatus:statusCode];
    }
}

@end
