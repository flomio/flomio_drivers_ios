//
//  FLOReader.m
//  
//
//  Originally created by Thomas Schmid on 8/4/11.
//  Licensed under the New BSD Licensce (http://opensource.org/licenses/BSD-3-Clause)
//

#import "FLOReader.h"
#import "FloBLEReader.h"

#define MESSAGE_SYNC_TIMEOUT        .500    // seconds

@interface FLOReader()
- (void)clearMessageBuffer;
@end

@implementation FLOReader
{
    id <FLOReaderDelegate>	 _delegate;
    dispatch_queue_t             _backgroundQueue;
    
    // NFC Service state variables
    UInt8						 _byteForTX;
    BOOL						 _byteQueuedForTX;
    BOOL                         _currentlySendingMessage;
    BOOL						 _muteEnabled;
    
    // Message handling variables
    double                       _lastByteReceivedAtTime;
    UInt8                        _messageCRC;
    NSMutableData               *_messageReceiveBuffer;
    int                          _messageLength;
    BOOL                         _messageValid;
}

@synthesize delegate = _delegate;
//@synthesize messageTXLock = _messageTXLock;
@synthesize deviceConnected = _deviceConnected;;

#pragma mark - NFC Service (Objective C)

/**
 Designated initializer for FLOReader. Initializes decoder state
 and preps audio session for decoding process. 
 
 @return FLOReader
 */
- (id)init {
    self = [super init];
    if (self) {
        // Setup Grand Central Dispatch queue (thread pool)
        _backgroundQueue = dispatch_queue_create("com.flomio.bg", NULL);
// not supported with ARC        dispatch_retain(_backgroundQueue);
        
        
        // Initialize receive handler buffer
        _messageReceiveBuffer = [[NSMutableData alloc] initWithCapacity:MAX_MESSAGE_LENGTH];
        _messageLength = MAX_MESSAGE_LENGTH;
        _messageCRC = 0;
        
        // Init state flags
        _currentlySendingMessage = FALSE;
        _muteEnabled = FALSE;    
        _byteQueuedForTX = FALSE;
        
//        _messageTXLock = dispatch_semaphore_create(1);
//        _ignoreRouteChangeCount = 0;
        
        // Assume non EU device
//        [self setOutputAmplitudeNormal];
        _deviceConnected = NO;
         
        NSLog(@"Inited FJNCServices");
    }
    return self;
}

- (void)clearMessageBuffer {
    [_messageReceiveBuffer setLength:0];
    _messageLength  = MAX_MESSAGE_LENGTH;
    _messageCRC = 0;
}

/**
 Get current audio route description and determine if reader is connected.  This method is called VERY often.  Keep it light
 and be concisous of memory leaks.
 
 @return BOOL    Reader connected status
 */
- (BOOL)isDeviceConnected
{
    return _deviceConnected;
}

/**
 Process the decoded byte. If parity is correct and the message sync timeout 
 hasn't passed, this byte will be added to the receive message buffer.
 Otherwise the receive message buffer is marked invalid and cleared when 
 transmission has finished.
 
 @param byte             Decoded byte
 @param withParity       Parity check was successful
 @param atTimestamp      Decoding timestamp
 @return void
 */
- (void)handleReceivedByte:(UInt8)byte withParity:(BOOL)parityGood atTimestamp:(double)timestamp {
    /*
     *  ERROR CHECKING 
     */
    // Before anything else carry out error handling
    if (!parityGood) {
        // last byte was corrupted, dump this entire message
//        LogTrace(@" --- Parity Bad: dumping message.");
        NSLog(@" --- Parity Bad: dumping message.");
        [self markCurrentMessageCorruptAndClearBufferAtTime:timestamp];
        return;
    }
    else if (!_messageValid && !(timestamp - _lastByteReceivedAtTime >= MESSAGE_SYNC_TIMEOUT)) {
        // byte is ok but we're still receiving a corrupt message, dump it.
//        LogTrace(@" --- Message Invalid: dumping message (timeout: %f)", (timestamp - _lastByteReceivedAtTime));
        NSLog(@" --- Message Invalid: dumping message (timeout: %f)", (timestamp - _lastByteReceivedAtTime));
        return;
    }
    else if (timestamp - _lastByteReceivedAtTime >= MESSAGE_SYNC_TIMEOUT) {       
        // sweet! timeout has passed, let's get cranking on this valid message
        if (_messageReceiveBuffer.length > 0) {
//            LogError(@"Timeout reached. Dumping previous buffer. \n_messageReceiveBuffer:%@ \n_messageReceiveBuffer.length:%d", [_messageReceiveBuffer fj_asHexString], _messageReceiveBuffer.length);
            NSLog(@"Timeout reached. Dumping previous buffer. \n_messageReceiveBuffer:%@ \n_messageReceiveBuffer.length:%d", [_messageReceiveBuffer fj_asHexString], _messageReceiveBuffer.length);
           
            if([_delegate respondsToSelector:@selector(nfcService: didHaveError:)]) {
                dispatch_async(_backgroundQueue, ^(void) {
                    [_delegate nfcService:self didHaveError:FLOMIO_STATUS_MESSAGE_CORRUPT_ERROR];
                });
            }
        }
        
//        LogTrace(@" ++ Message Valid: byte is part of a new message (timeout: %f)", (timestamp - _lastByteReceivedAtTime));
        NSLog(@" ++ Message Valid: byte is part of a new message (timeout: %f)", (timestamp - _lastByteReceivedAtTime));
        [self markCurrentMessageValidAtTime:timestamp];
        [self clearMessageBuffer];
    }

    /*
     *  BUFFER BUILDER
     */
    [self markCurrentMessageValidAtTime:timestamp];
    [_messageReceiveBuffer appendBytes:&byte length:1];
    _messageCRC ^= byte;
    
    // Have we received the message length yet ?
    if (_messageReceiveBuffer.length == 2) {
        UInt8 length = 0;
        [_messageReceiveBuffer getBytes:&length
                                      range:NSMakeRange(FLO_MESSAGE_LENGTH_POSITION,
                                                        FLO_MESSAGE_LENGTH_LENGTH)];
        _messageLength = length;
        if (_messageLength < MIN_MESSAGE_LENGTH || _messageLength > MAX_MESSAGE_LENGTH)
        {
 //           LogError(@"Invalid message length, ignoring current message.");
            NSLog(@"Invalid message length, ignoring current message.");
            [self markCurrentMessageCorruptAndClearBufferAtTime:timestamp];
        }
    }
    
    // Is the message complete?
    if (_messageReceiveBuffer.length == _messageLength
        && _messageReceiveBuffer.length > MIN_MESSAGE_LENGTH)        
    {
        // Check CRC
        if (_messageCRC == CORRECT_CRC_VALUE) {
            // Well formed message received, pass it to the delegate
//            LogInfo(@"FLOReader: Complete message, send to delegate.");
            NSLog(@"FLOReader: Complete message, send to delegate.");
            
            if([_delegate respondsToSelector:@selector(nfcService: didReceiveMessage:)]) {
                NSData *dataCopy = [[NSData alloc] initWithData:_messageReceiveBuffer];
                dispatch_async(_backgroundQueue, ^(void) {
                    [_delegate nfcService:self didReceiveMessage:dataCopy];
                });
            }
            
            [self markCurrentMessageValidAtTime:timestamp];
            [self clearMessageBuffer];            
        }
        else {
            //TODO: plumb this through to delegate
//            LogError(@"Bad CRC, ignoring current message.");
            NSLog(@"Bad CRC, ignoring current message.");
           [self markCurrentMessageCorruptAndClearBufferAtTime:timestamp];
        }
    }
}

/**
 Mark the current message corrupt and clear the receive buffer.
 
 @param timestamp       Time when message was marked valid and buffer cleared
 @return void
 */
- (void)markCurrentMessageCorruptAndClearBufferAtTime:(double)timestamp {
    [self markCurrentMessageCorruptAtTime:timestamp];
    [self clearMessageBuffer];
}

/**
 Mark the current message invalid and timestamp.
 The message receive buffer will be flushed after transmission
 completes.
 
 @param timestamp       Time when message was marked corrupt
 @return void
 */
- (void)markCurrentMessageCorruptAtTime:(double)timestamp {
    _lastByteReceivedAtTime = timestamp;
    _messageValid = false;
}

/**
 Mark the current message valid and capture the timestamp.
 
 @param timestamp       Time when message was marked valid
 @return void
 */
- (void)markCurrentMessageValidAtTime:(double)timestamp {
    _lastByteReceivedAtTime = timestamp;
    _messageValid = true;
}

/**
 Queues up and sends a single byte across the audio line.
 
 @param theByte             The byte to be sent
 @return int                1 for byte queued, 0 for byte sent
 */
- (int)send:(UInt8)byte {
	if (_byteQueuedForTX == FALSE) {
		// transmitter ready
		_byteForTX = byte;
		_byteQueuedForTX = TRUE;
		return 0;
	} else {
		return 1;
	}
}

/**
 Send one byte.
 
 @param theByte             The byte to be sent
 @return void
 */
- (void)sendByteToHost:(UInt8)theByte {
    // Keep transmitting the message until it's sent on the line
    while ([self send:theByte]);
}


/**
 Send a message to the Reader device. Message definitions can be found in device spec.
 
 @param messageData        NSData representing the FJ Message
 @return void
 */
- (BOOL)sendMessageDataToHost:(NSData *)messageData {

    UInt8 * uartByte = (UInt8*)messageData.bytes;
    int len = [messageData length];
    NSMutableString * string = [[NSMutableString alloc]init];
    
    for (int i = 0; i < len-1; i++)
    {
        [string appendString:[NSString stringWithFormat:@"%2.2x:",uartByte[i]]];
    }
    [string appendString:[NSString stringWithFormat:@"%2.2x",uartByte[len-1]]];
    NSLog(@"JFNFCservice sendMessageDataToHost %@",string);
    

    for (int i = 0; i < len; i++)
    {
        BOOL parityGood = YES;
//       [self handleReceivedByte:uartByte[i] withParity:parityGood atTimestamp:CACurrentMediaTime()];
       [self handleReceivedByte:uartByte[i] withParity:parityGood atTimestamp:[NSDate timeIntervalSinceReferenceDate]];
   }

    return true;
}

/**
 Deallocate the NFC Service.
 
 @return void
 */
- (void)dealloc
{
//	delete[] _remoteIODCFilter;
// not supported with ARC    dispatch_release(_backgroundQueue);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
