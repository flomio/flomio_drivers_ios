//
//  FJNFCService.m
//  FloJack
//
//  Originally created by Thomas Schmid on 8/4/11.
//  Licensed under the New BSD Licensce (http://opensource.org/licenses/BSD-3-Clause)
//

#import "FJNFCService.h"

// Sample rate calculation
#define fc                          1200
#define df                          100
#define T                           (1/df)
#define N                           (SInt32)(T * nfcService->_hwSampleRate)

#define ZERO_TO_ONE_THRESHOLD       0       // threshold used to detect start bit

//#define SAMPLESPERBIT               32      // (44100 / HIGHFREQ)  // how many samples per UART bit
//#define SAMPLESPERBIT               24      // (44100 / HIGHFREQ)  // how many samples per UART bit
//#define SAMPLESPERBIT               22      // (44100 / HIGHFREQ)  // how many samples per UART bit
#define SAMPLESPERBIT               13      // (44100 / HIGHFREQ)  // how many samples per UART bit
//#define SAMPLESPERBIT               7      // (44100 / HIGHFREQ)  // how many samples per UART bit
#define SHORT                       (SAMPLESPERBIT/2 + SAMPLESPERBIT/4)
#define LONG                        (SAMPLESPERBIT + SAMPLESPERBIT/2)

//#define HIGHFREQ                    1378.125 // baud rate. best to take a divisible number for 44.1kS/s
//#define HIGHFREQ                    1837.5 // baud rate. best to take a divisible number for 44.1kS/s
//#define HIGHFREQ                    2000 // baud rate. best to take a divisible number for 44.1kS/s
#define HIGHFREQ                    3392 // baud rate. best to take a divisible number for 44.1kS/s
//#define HIGHFREQ                    6300 // baud rate. best to take a divisible number for 44.1kS/s
#define LOWFREQ                     (HIGHFREQ / 2)
    
//#define NUMSTOPBITS                 18      // number of stop bits to send before sending next value.
#define NUMSTOPBITS                 20      // number of stop bits to send before sending next value.
#define NUMSYNCBITS                 4       // number of ones to send before sending first value.

#define SAMPLE_NOISE_CEILING         100000 // keeping running average and filter out noisy values around 0
#define SAMPLE_NOISE_FLOOR          -100000 // keeping running average and filter out noisy values around 0

#define MESSAGE_SYNC_TIMEOUT        .500    // seconds

enum uart_state {
	STARTBIT = 0,
	SAMEBIT  = 1,
	NEXTBIT  = 2,
	STOPBIT  = 3,
	STARTBIT_FALL = 4,
	DECODE_BYTE_SAMPLE   = 5,
};

@interface FJNFCService()
- (void)handleReceivedByte:(UInt8)byte withParity:(BOOL)parityGood atTimestamp:(double)timestamp;
- (void)sendFloJackConnectedStatusToDelegate;
- (void)clearMessageBuffer;
@end

@implementation FJNFCService
{
    id <FJNFCServiceDelegate>	 _delegate;
    dispatch_queue_t             _backgroundQueue;
	
    // Audio Unit attributes
    AURenderCallbackStruct		 _audioUnitRenderCallback;
    Float64						 _hwSampleRate;
    UInt32						 _maxFPS;
    DCRejectionFilter			*_remoteIODCFilter;
    AudioUnit					 _remoteIOUnit;
    CAStreamBasicDescription	 _remoteIOOutputFormat;
    UInt8                        _ignoreRouteChangeCount;
    
    // NFC Service state variables
    UInt8						 _byteForTX;
    BOOL						 _byteQueuedForTX;
    BOOL                         _currentlySendingMessage;
    BOOL						 _muteEnabled;
    
    // Logic Values
    UInt8                        _logicOne;
    UInt8                        _logicZero;
    
    // Message handling variables
    double                       _lastByteReceivedAtTime;
    UInt8                        _messageCRC;
    NSMutableData               *_messageReceiveBuffer;
    int                          _messageLength;
    BOOL                         _messageValid;
}

@synthesize delegate = _delegate;
@synthesize messageTXLock = _messageTXLock;
@synthesize outputAmplitude = _outputAmplitude;

#pragma mark - NFC Service Audio Sessions and Callbacks (C)

/**
 Invoked when an audio interruption in iOS begins or ends.
 
 @param inClientData            Data that you specified in the inClientData parameter of the AudioSessionInitialize function. Can be NULL.
 @param inInterruptionState     A constant that indicates whether the interruption has just started or just ended. See “Audio Session Interruption States.”
 @return void
 */
void floJackAudioSessionInterruptionListener(void   *inClientData,
                                             UInt32 inInterruption)
{
	printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
	
	FJNFCService *nfcService = (FJNFCService *) CFBridgingRelease(inClientData);
	
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
		AudioSessionSetActive(true);
		//OSStatus status = AudioOutputUnitStart(nfcService->_remoteIOUnit);
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
        AudioOutputUnitStop(nfcService->_remoteIOUnit);
    }
}

/**
 Invoked when an audio session property changes in iOS.
 
 @param inClientData        Data that you specified in the inClientData parameter of the AudioSessionAddPropertyListener function. Can be NULL.
 @param inID                The identifier for the audio session property whose value just changed. See “Audio Session Property Identifiers.”
 @param inDataSize          The size, in bytes, of the value of the changed property.
 @param inData              The new value of the changed property.
 @return void
 */
void floJackAudioSessionPropertyListener(void *                  inClientData,
                                         AudioSessionPropertyID  inID,
                                         UInt32                  inDataSize,
                                         const void *            inData)
{
    
    FJNFCService *self = (__bridge FJNFCService *)inClientData;
       
    if (inID == kAudioSessionProperty_AudioRouteChange) {
		try {
            // if there was a route change, we need to dispose the current rio unit and create a new one
			XThrowIfError(AudioComponentInstanceDispose(self->_remoteIOUnit), "couldn't dispose remote i/o unit");
			SetupRemoteIO(self->_remoteIOUnit, self->_audioUnitRenderCallback, self->_remoteIOOutputFormat);
			
			UInt32 size = sizeof(self->_hwSampleRate);
			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &self->_hwSampleRate), "couldn't get new sample rate");
			XThrowIfError(AudioOutputUnitStart(self->_remoteIOUnit), "couldn't start unit");
            
            // send interbyte delay config message if FloJack reconnected
            NSString *currentRoute = [(__bridge NSDictionary *)inData objectForKey:@"OutputDeviceDidChange_NewRoute"];
            NSLog(@"Current Route: %@", currentRoute);            
            [self sendFloJackConnectedStatusToDelegate];

		}
        catch (CAXException e) {
			char buf[256];
			fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		}
	}
    else if (inID == kAudioSessionProperty_CurrentHardwareOutputVolume) {
        [self checkIfVolumeLevelMaxAndNotifyDelegate];
    }
}


/**
 Called by the system when an audio unit requires input samples, or before and after a render operation.
 host registers callback with audio unit in preparation to send data
 
 @param inRefCon        Custom data that you provided when registering your callback with the audio unit.
 @param ioActionFlags   Flags used to describe more about the context of this call (pre or post in the notify case for instance).
 @param inTimeStamp     The timestamp associated with this call of audio unit render.
 @param inBusNumber     The bus number associated with this call of audio unit render.
 @param inNumberFrames  The number of sample frames that will be represented in the audio data in the provided ioData parameter.
 @param ioData          The AudioBufferList that will be used to contain the rendered or provided audio data.
 @return OSStatus indicator.
 */
static OSStatus	floJackAURenderCallback(void						*inRefCon,
                                        AudioUnitRenderActionFlags 	*ioActionFlags, 
                                        const AudioTimeStamp 		*inTimeStamp, 
                                        UInt32 						inBusNumber, 
                                        UInt32 						inNumberFrames, 
                                        AudioBufferList 			*ioData)
{
    FJNFCService *self = (__bridge FJNFCService *)inRefCon;
	OSStatus ossError = AudioUnitRender(self->_remoteIOUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	
    if (ossError) {
        printf("AudioUnitRender Error:%d\n", (int)ossError);
        return ossError;
    }
    else if (!self.floJackConnected) {
        SilenceData(ioData);
        return ossError;
    }    
    
    // TX vars
	static int byteCounter = 1;
    static int decoderState = STARTBIT;
    static SInt32 lastSample = 0;
    static UInt32 lastPhase2 = 0;
    static UInt8 parityTx = 0;
    static UInt32 phase = 0;
	static UInt32 phase2 = 0;
	static SInt32 sample = 0;
	
	// UART decoding
	static int bitNum = 0;
	static BOOL parityGood = 0;
    static uint8_t uartByte = 0;    
	
	// UART encode
	static BOOL comm_sync_in_progress = FALSE;
    static uint8_t currentBit = 1;
    static uint8_t encoderState = NEXTBIT;
    static uint32_t nextPhaseEnc = SAMPLESPERBIT;
    static UInt8 parityRx = 0;
    static uint32_t phaseEnc = 0;
    static float sample_avg_low = 0;
    static float sample_avg_high = 0;   
    static uint8_t uartByteTx = 0x0;
	static uint32_t uartBitTx = 0;
	static float uartBitEnc[SAMPLESPERBIT];
    static uint32_t uartSyncBitTx = 0;
	
	// Audio Channels
	SInt32* left_audio_channel = (SInt32*)(ioData->mBuffers[0].mData);
	
	
    /************************************
	 * UART Decoding
	 ************************************/
	for(int frameIndex = 0; frameIndex<inNumberFrames; frameIndex++) {
		float raw_sample = left_audio_channel[frameIndex];
        //left_audio_channel[frameIndex] = 0;
        LogWaveform(@"%8ld, %8.0f\n", phase2, raw_sample);

		if(decoderState == DECODE_BYTE_SAMPLE )
			LogDecoderVerbose(@"%8ld, %8.0f, %d\n", phase2, raw_sample, frameIndex);

		phase2 += 1;
		if (raw_sample < ZERO_TO_ONE_THRESHOLD) {
            sample = self->_logicZero;
            sample_avg_low = (sample_avg_low + raw_sample)/2;
		}
        else {
            sample = self->_logicOne;
            sample_avg_high = (sample_avg_high + raw_sample)/2;
		}
        
        if ((sample != lastSample) && (sample_avg_high > SAMPLE_NOISE_CEILING) && (sample_avg_low < SAMPLE_NOISE_FLOOR)) {
			// we have a transition
			SInt32 diff = phase2 - lastPhase2;
			switch (decoderState) {
				case STARTBIT:
					if (lastSample == 0 && sample == 1) {
						// low->high transition. Now wait for a long period
						decoderState = STARTBIT_FALL;
					}
					break;
				case STARTBIT_FALL:
					if ((SHORT < diff) && (diff < LONG)) {
						// looks like we got a 1->0 transition.
						LogDecoder(@"Received a valid StartBit \n");
                        decoderState = DECODE_BYTE_SAMPLE;
                        bitNum = 0;
						parityRx = 0;
						uartByte = 0;
					}
                    else {
						// looks like we didn't
                        decoderState = STARTBIT;
					}
					break;
				case DECODE_BYTE_SAMPLE:
					if ((SHORT < diff) && (diff < LONG)) {
						// We have a valid sample.
						if (bitNum < 8) {
							// Sample is part of the byte
                            //LogDecoder(@"Bit %d value %ld diff %ld parity %d\n", bitNum, sample, diff, parityRx & 0x01);
                            uartByte = ((uartByte >> 1) + (sample << 7));
							bitNum += 1;
							parityRx += sample;
						}
                        else if (bitNum == 8) {
							// Sample is a parity bit
							if(sample != (parityRx & 0x01)) {
                                LogError(@" -- parity %ld,  UartByte 0x%x\n", sample, uartByte);
                                //decoderState = STARTBIT;
                                parityGood = false;
                                bitNum += 1;
							}
                            else {
                                LogTrace(@" ++ UartByte: 0x%x\n", uartByte);
                                //LogTrace(@" +++ good parity: %ld \n", sample);
								parityGood = true;
                                bitNum += 1;                                
							}							
						}
                        else {
							// Sample is stop bit
							if (sample == 1) {
								// Valid byte
                                //LogTrace(@" +++ stop bit: %ld \n", sample);
//                                if(frameIndex > (80))
//                                {
//                                    //LogError(@"%f\n", raw_sample);
//                                    for(int k=frameIndex-80; k<256; k++)
//                                    {
//                                        NSLog(@"%d\n", left_audio_channel[k]);
//                                    }
//                                    NSLog(@"%f\n", raw_sample);
//                                }
							}
                            else {
								// Invalid byte			
                                LogError(@" -- StopBit: %ld UartByte 0x%x\n", sample, uartByte);
                                parityGood = false;
							}
                            
                            // Send bye to message handler
                            //NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
                            @autoreleasepool {
                                [self handleReceivedByte:uartByte withParity:parityGood atTimestamp:CACurrentMediaTime()];
                            }
                            //[autoreleasepool release];
                            
							decoderState = STARTBIT;
						}
					}
                    else if (diff > LONG) {
                        LogDecoder(@"Diff too long %ld\n", diff);
						decoderState = STARTBIT;
					}
                    else {
						// don't update the phase as we have to look for the next transition
						lastSample = sample;
						continue;
					}
					
					break;
				default:
					break;
			}
			lastPhase2 = phase2;
		}
		lastSample = sample;
	} //end: for(int j = 0; j < inNumberFrames; j++) 
	
	if (self->_muteEnabled == NO) {
		// Prepare the sine wave
		SInt32 values[inNumberFrames];
		
        /*******************************
		 * Generate 22kHz Tone
		 *******************************/	
		double waves;
		for(int j = 0; j < inNumberFrames; j++) {
			waves = 0;
			waves += sin(M_PI * phase+0.5); // nfcService should be 22.050kHz
			waves *= (self->_outputAmplitude); // <--------- make sure to divide by how many waves you're stacking

			values[j] = (SInt32)waves;
			phase++;			
		}

		/*******************************
		 * UART Encoding
		 *******************************/
		for(int j = 0; j<inNumberFrames && self->_currentlySendingMessage == TRUE; j++) {
			if (phaseEnc >= nextPhaseEnc) {
                if(self->_byteQueuedForTX == TRUE && uartBitTx >= NUMSTOPBITS && comm_sync_in_progress == FALSE) {
                    comm_sync_in_progress = TRUE;
                    encoderState = NEXTBIT;
                    uartSyncBitTx = 0;
                }
				else if (self->_byteQueuedForTX == TRUE && uartBitTx >= NUMSTOPBITS && uartSyncBitTx >= NUMSYNCBITS) {
                    encoderState = STARTBIT;
				}
                else {
					encoderState = NEXTBIT;
				}
			} //end: if (phaseEnc >= nextPhaseEnc)
			
			switch (encoderState) {
				case STARTBIT:
				{
					uartByteTx = self->_byteForTX;
                    self->_byteQueuedForTX = FALSE;

                    LogTrace(@"uartByteTx: 0x%x\n", uartByteTx);
					
                    byteCounter += 1;
					uartBitTx = 0;
					parityTx = 0;
					
					encoderState = NEXTBIT;
					// break;   // fall through intentionally
				}
				case NEXTBIT:
				{
					uint8_t nextBit;
					if (uartBitTx == 0) {
						// start bit
						nextBit = 0;
					} else {
						if (uartBitTx == 9) {
							// parity bit
							nextBit = parityTx & 0x01;
						}
                        else if (uartBitTx >= 10) {
							// stop bit
							nextBit = 1;
						}
                        else {
							nextBit = (uartByteTx >> (uartBitTx - 1)) & 0x01;
							parityTx += nextBit;
						}
					}
					if (nextBit == currentBit) {
						if (nextBit == 0) {
							for( uint8_t p = 0; p<SAMPLESPERBIT; p++) {
								uartBitEnc[p] = -sin(M_PI * 2.0f / self->_hwSampleRate * HIGHFREQ * (p+1));
							}
						}
                        else {
							for( uint8_t p = 0; p<SAMPLESPERBIT; p++) {
								uartBitEnc[p] = sin(M_PI * 2.0f / self->_hwSampleRate * HIGHFREQ * (p+1));
							}
						}
					} else {
						if (nextBit == 0) {
							for( uint8_t p = 0; p<SAMPLESPERBIT; p++) {
								uartBitEnc[p] = sin(M_PI * 2.0f / self->_hwSampleRate * LOWFREQ * (p+1));
							}
						} else {
							for( uint8_t p = 0; p<SAMPLESPERBIT; p++) {
								uartBitEnc[p] = -sin(M_PI * 2.0f / self->_hwSampleRate * LOWFREQ * (p+1));
							}
						}
					}
					currentBit = nextBit;
					uartBitTx++;
					encoderState = SAMEBIT;
					phaseEnc = 0;
					nextPhaseEnc = SAMPLESPERBIT;
					
					break;
				}
				default:
					break;
			} //end: switch(state)
            values[j] = (SInt32)(uartBitEnc[phaseEnc%SAMPLESPERBIT] * self->_outputAmplitude);
            phaseEnc++;
		} //end: for(int j = 0; j< inNumberFrames; j++) 
        // copy data into left channel
        if((uartBitTx<=NUMSTOPBITS || uartSyncBitTx<=NUMSYNCBITS) && self->_currentlySendingMessage == TRUE) {
            memcpy(ioData->mBuffers[0].mData, values, ioData->mBuffers[0].mDataByteSize);
            uartSyncBitTx++;
        }
        else {
            comm_sync_in_progress = FALSE;
            SilenceData(ioData);
        }
	}
    
    
	return ossError;
}

#pragma mark - NFC Service (Objective C)

/**
 Designated initializer for FJNFCService. Initializes decoder state
 and preps audio session for decoding process. 
 
 @return FJNFCService
 */
- (id)init {
    self = [super init];
    if (self) {
        // Setup Grand Central Dispatch queue (thread pool)
        _backgroundQueue = dispatch_queue_create("com.flomio.flojack", NULL);
        dispatch_retain(_backgroundQueue);
        
        // Register an input callback function with an audio unit.
        _audioUnitRenderCallback.inputProc = floJackAURenderCallback;
        _audioUnitRenderCallback.inputProcRefCon = (__bridge_retained void*) self;
        
        // Initialize receive handler buffer
        _messageReceiveBuffer = [[NSMutableData alloc] initWithCapacity:MAX_MESSAGE_LENGTH];
        _messageLength = MAX_MESSAGE_LENGTH;
        _messageCRC = 0;
        
        // Init state flags
        _currentlySendingMessage = FALSE;
        _muteEnabled = FALSE;    
        _byteQueuedForTX = FALSE;
        
        _messageTXLock = dispatch_semaphore_create(1);
        _ignoreRouteChangeCount = 0;
        
        // Assume non EU device
        [self setOutputAmplitudeNormal];
        
        try {
            // Logic high/low varies based on host device        
            _logicOne = [FJNFCService getDeviceLogicOneValue];
            _logicZero = [FJNFCService getDeviceLogicZeroValue];
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                XThrowIfError(AudioSessionInitialize(NULL, NULL, floJackAudioSessionInterruptionListener, (__bridge_retained void*) self), "couldn't initialize audio session");

            
            // Initialize and configure the audio session
            XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
            
            UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
            XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "couldn't set audio category");
            XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, floJackAudioSessionPropertyListener, (__bridge_retained void*) self), "couldn't set property listener");
            
            Float32 preferredBufferSize = .005;
            XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize), "couldn't set i/o buffer duration");
            
            UInt32 size = sizeof(_hwSampleRate);
            XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &_hwSampleRate), "couldn't get hw sample rate");
                
            XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, floJackAudioSessionPropertyListener, (__bridge_retained void*) self), "couldn't set property listener");
                
            XThrowIfError(SetupRemoteIO(_remoteIOUnit, _audioUnitRenderCallback, _remoteIOOutputFormat), "couldn't setup remote i/o unit");
            
            _remoteIODCFilter = new DCRejectionFilter[_remoteIOOutputFormat.NumberChannels()];
            
            size = sizeof(_maxFPS);
            XThrowIfError(AudioUnitGetProperty(_remoteIOUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &_maxFPS, &size), "couldn't get the remote I/O unit's max frames per slice");
            
            XThrowIfError(AudioOutputUnitStart(_remoteIOUnit), "couldn't start remote i/o unit");
            
            size = sizeof(_remoteIOOutputFormat);
            XThrowIfError(AudioUnitGetProperty(_remoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &_remoteIOOutputFormat, &size), "couldn't get the remote I/O unit's output client format");
            });
        }
        catch (CAXException &e) {
            char buf[256];
            fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
            if (_remoteIODCFilter) delete[] _remoteIODCFilter;
        }
        catch (...) {
            fprintf(stderr, "An unknown error occurred\n");
            if (_remoteIODCFilter) delete[] _remoteIODCFilter;
        }
        

    }
    return self;
}

/*
 Checks if the current route's volume is at MAX value.
 Returns a BOOL and sends status to NFC Service Delegate
 to handle and propopgate to consuming app.
 
 @return BOOL   volume level acceptable or not
 */
- (BOOL)checkIfVolumeLevelMaxAndNotifyDelegate; {
    Float32 volume;
    UInt32 dataSize = sizeof(Float32);
    AudioSessionGetProperty (kAudioSessionProperty_CurrentHardwareOutputVolume,
                             &dataSize,
                             &volume
                             );
    
    NSInteger volumeStatus;
    BOOL volumeStatusBool;
    if (volume == 1) {
        volumeStatus = FLOMIO_STATUS_VOLUME_OK;
        volumeStatusBool = true;
    }
    else {
        volumeStatus = FLOMIO_STATUS_VOLUME_LOW_ERROR;
        volumeStatusBool = false;
    }
    
    if (self.floJackConnected) {
        if([_delegate respondsToSelector:@selector(nfcService: didHaveError:)]) {
            dispatch_async(_backgroundQueue, ^(void) {
                [self.delegate nfcService:self didHaveError:volumeStatus];
            });
        }
    }
    return volumeStatusBool;
}

- (void)clearMessageBuffer {
    [_messageReceiveBuffer setLength:0];
    _messageLength  = MAX_MESSAGE_LENGTH;
    _messageCRC = 0;
}

/**
 Switches route to HeadSetInOut and enabled FloJack audio line communication.
 
 @return BOOL indicates if execution was successful
 */
- (BOOL)disableDeviceSpeakerPlayback {
    BOOL success;
    
    NSError *sharedAudioSessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sharedAudioSessionError];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    OSStatus setPropertyRouteError  = 0;
    setPropertyRouteError = AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    NSError *sharedAudioSessionSetActiveError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if (sharedAudioSessionError != nil || setPropertyRouteError != 0 || sharedAudioSessionSetActiveError != nil) {
        LogError("AudioSession Error(s): %@, %@, %@", sharedAudioSessionError.localizedDescription, [FJAudioSessionHelper formatOSStatus:setPropertyRouteError], sharedAudioSessionSetActiveError.localizedDescription);
        success = false;
    }
    else {
        success = true;
        dispatch_semaphore_signal(_messageTXLock);
    }
    return success;
}

/**
 Disables FloJack audio line communication and switches route to device speaker.
 
 @return BOOL indicates if execution was successful
 */
- (BOOL)enableDeviceSpeakerPlayback {
    dispatch_semaphore_wait(_messageTXLock, DISPATCH_TIME_FOREVER);
    BOOL success = true;
    
    NSError *sharedAudioSessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sharedAudioSessionError];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    OSStatus setPropertyRouteError  = 0;
    setPropertyRouteError = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    if (sharedAudioSessionError != nil || setPropertyRouteError != 0) {
        LogError("AudioSession Error(s): %@, %@", sharedAudioSessionError.localizedDescription, [FJAudioSessionHelper formatOSStatus:setPropertyRouteError]);
        dispatch_semaphore_signal(_messageTXLock);
        success = false;
    }
    else {
        success = false;
        _ignoreRouteChangeCount = 2;        
    }
    return success;
}

/**
 Get current audio route description and determine if FloJack is connected.  
 
 @return BOOL    FloJack connected status
 */
- (BOOL)floJackConnected {
    CFDictionaryRef route;
    UInt32 size = sizeof(route);
    XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &size, &route), "couldn't get new sample rate");
    
    NSDictionary *inputRoutes = [(NSArray *)[(__bridge NSDictionary *)route objectForKey:@"RouteDetailedDescription_Inputs"] objectAtIndex:0];
    NSDictionary *outputRoutes = [(NSArray *)[(__bridge NSDictionary *)route objectForKey:@"RouteDetailedDescription_Outputs"] objectAtIndex:0];
    
    if ([[inputRoutes objectForKey:@"RouteDetailedDescription_PortType"] isEqual: @"MicrophoneWired"] &&
        [[outputRoutes objectForKey:@"RouteDetailedDescription_PortType"] isEqual: @"Headphones"]) {
        return true;
    }
    else {
        return false;
    }
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
    if (not parityGood) {
        // last byte was corrupted, dump this entire message
        LogTrace(@" --- Parity Bad: dumping message.");
        [self markCurrentMessageCorruptAndClearBufferAtTime:timestamp];
        return;
    }
    else if (not _messageValid and not (timestamp - _lastByteReceivedAtTime >= MESSAGE_SYNC_TIMEOUT)) {
        // byte is ok but we're still receiving a corrupt message, dump it.
        LogTrace(@" --- Message Invalid: dumping message (timeout: %f)", (timestamp - _lastByteReceivedAtTime));
        [self markCurrentMessageCorruptAndClearBufferAtTime:timestamp];
        return;
    }
    else if (timestamp - _lastByteReceivedAtTime >= MESSAGE_SYNC_TIMEOUT) {       
        // sweet! timeout has passed, let's get cranking on this valid message
        if (_messageReceiveBuffer.length > 0) {
            LogError(@"Timeout reached. Dumping previous buffer. \n_messageReceiveBuffer:%@ \n_messageReceiveBuffer.length:%d", [_messageReceiveBuffer fj_asHexString], _messageReceiveBuffer.length);
            
            if([_delegate respondsToSelector:@selector(nfcService: didHaveError:)]) {
                dispatch_async(_backgroundQueue, ^(void) {
                    [_delegate nfcService:self didHaveError:FLOMIO_STATUS_MESSAGE_CORRUPT_ERROR];
                });
            }
        }
        
        LogTrace(@" ++ Message Valid: byte is part of a new message (timeout: %f)", (timestamp - _lastByteReceivedAtTime));
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
                                      range:NSMakeRange(FLOJACK_MESSAGE_LENGTH_POSITION,
                                                        FLOJACK_MESSAGE_LENGTH_POSITION)];
        _messageLength = length;
        if (_messageLength < MIN_MESSAGE_LENGTH || _messageLength > MAX_MESSAGE_LENGTH)
        {
            LogError(@"Invalid message length, ingoring current message.");
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
            LogInfo(@"FJNFCService: Complete message, send to delegate.");
            
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
            LogError(@"Bad CRC, ingoring current message.");
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

/*
 Used to increase the output wave amplitude to 1<<27. 
 This is necessary for EU devices with audio caps at ~80dBA.
 
 WARNING:   IMPROPER USE CAN DAMAGE THE FLOJACK DEVICE.
            DO NOT USE ON NON AUDIO CAPPED DEVICES.
 
 @return void
 */
- (void)setOutputAmplitudeHigh {
    _outputAmplitude = (1<<27);
}

/*
 Used to initialize output amplitude to normal levels. 
 For use on non-EU devices with full 120 dBA audio outputs.
 
 @return void
 */
- (void)setOutputAmplitudeNormal {
    _outputAmplitude = (1<<24);
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
 Send one byte across the audio jack to the FloJack.
 
 @param theByte             The byte to be sent
 @return void
 */
- (void)sendByteToHost:(UInt8)theByte {
    // Keep transmitting the message until it's sent on the line
    while ([self send:theByte]);
}

/**
 Tell consuming app (by way of adapter) if the FloJack is plugged in
 
 @return void
 */
- (void)sendFloJackConnectedStatusToDelegate {
    if (_ignoreRouteChangeCount > 0) {
        _ignoreRouteChangeCount--;
        return;
    }
    
    if([_delegate respondsToSelector:@selector(nfcServiceDidReceiveFloJack: connectedStatus:)]) {
        dispatch_async(_backgroundQueue, ^(void) {
            [_delegate nfcServiceDidReceiveFloJack:self connectedStatus:self.floJackConnected];
        });
    }
}

/**
 Send a message to the FloJack device. Message definitions can be found in device spec.
 
 @param messageData        NSData representing the FJ Message
 @return void
 */
- (BOOL)sendMessageDataToHost:(NSData *)messageData {
    if (!self.floJackConnected) {
        [self sendFloJackConnectedStatusToDelegate];
        return false;
    }
    
    [NSThread sleepForTimeInterval:0.010];
    
    UInt8 *theMessage = (UInt8 *)messageData.bytes;
    int messageLength = messageData.length;
    
    dispatch_semaphore_wait(_messageTXLock, DISPATCH_TIME_FOREVER);
    _currentlySendingMessage = TRUE;
    
    LogInfo(@"sendMessageToHost begin");
    for(int i=0; i<messageLength; i++) {
        LogInfo(@"sendMessageToHost item: 0x%x", theMessage[i]);
        [self sendByteToHost:theMessage[i]];
    }
    LogInfo(@"sendMessageToHost end");
    
    // Give the last byte time to transmit
    [NSThread sleepForTimeInterval:.025];
    _currentlySendingMessage = FALSE;
    dispatch_semaphore_signal(_messageTXLock);
    
    return true;
}

/**
 Deallocate the NFC Service.
 
 @return void
 */
- (void)dealloc
{
	delete[] _remoteIODCFilter;
    dispatch_release(_backgroundQueue);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 This message configures the delay between bytes transmitted by
 the FloJack. For older devices we need to slow down to allow ample
 sampling time.
 
 TODO: iPad Mini Testing
 0x05 = (0x0C ^ 0x05 ^ 0x00)     // CRC calc
 0x0C, 0x05, 0x00, 0x06, 0x0F
 0x0C, 0x05, 0x00, 0x0B, 0x02
 0x0C, 0x05, 0x00, 0x0C, 0x05    // ipad 2
 0x0C, 0x05, 0x00, 0x50, 0x59    // 3gs
 0x0C, 0x05, 0x00, 0x80, 0x89    // flojack default
 0x0C, 0x05, 0x00, 0xFF, 0xF6
 
 @return UInt8    interbyte delay value
 */
+ (UInt8)getDeviceInterByteDelay{
    // Get the device model number from uname
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* machineName = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    
    UInt8 inter_byte_delay = 0x80;
    
    // Find delay based on device family
    if([machineName rangeOfString:@"iPad"].location != NSNotFound) {
        // iPad 4, 3, 2, 1
        inter_byte_delay = 0x0C;
    }
    else if([machineName rangeOfString:@"iPhone"].location != NSNotFound) {
        // iPhone 5, 4S, 4
        inter_byte_delay = 0x20;
    }
    else if([machineName rangeOfString:@"iPhone2"].location != NSNotFound) {
        // iPhone 3GS
        inter_byte_delay = 0x50;
    }
    else if([machineName rangeOfString:@"iPod"].location != NSNotFound) {
        // iPod Touch 1G, 2G, 3G, 4G, 5G
        inter_byte_delay = 0x50;
    } 
    
    return inter_byte_delay;
}

/**
 Get the Logic One value based on device type.
 
 @return UInt8    1 or 0 indicating logical one for this device
 */
+ (UInt8)getDeviceLogicOneValue  {
    // Get the device model number from uname
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* machineName = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    
    // Default value (should work on most devices)
    UInt8	logicOneValue = 1;
    
    // Device exceptions
    if([machineName caseInsensitiveCompare:@"iPhone2,1"] == NSOrderedSame) {
        // iPhone 3GS
        logicOneValue = 0;
    }
    else if([machineName caseInsensitiveCompare:@"iPhone1,2"] == NSOrderedSame) {
        // iPhone 3G
        logicOneValue = 0;
    }
    
    return logicOneValue;
}

/**
 Get the logical zero value based on device type.
 
 @return UInt8    1 or 0 indicating logical one for this device
 */
+ (UInt8)getDeviceLogicZeroValue  {
    // Return inverse of LogicOne value
    if ([FJNFCService getDeviceLogicOneValue] == 1)
        return 0;
    else
        return 1;
}

@end
