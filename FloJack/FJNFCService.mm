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

#define SAMPLESPERBIT               32      // (44100 / HIGHFREQ)  // how many samples per UART bit
#define SHORT                       (SAMPLESPERBIT/2 + SAMPLESPERBIT/4)
#define LONG                        (SAMPLESPERBIT + SAMPLESPERBIT/2)

#define HIGHFREQ                    1378.125 // baud rate. best to take a divisible number for 44.1kS/s
#define LOWFREQ                     (HIGHFREQ / 2)
    
#define NUMSTOPBITS                 18      // number of stop bits to send before sending next value.
#define NUMSYNCBITS                 4       // number of ones to send before sending first value.

#define SAMPLE_NOISE_CEILING        200000  // keeping running average and filter out noisy values around 0
#define SAMPLE_NOISE_FLOOR          -200000 // keeping running average and filter out noisy values around 0

//#define AMPLITUDE                   (1<<27) // EU: (1<<27) US: (1<<24)

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
- (BOOL)isHeadsetPluggedInWithRoute:(NSString *)currentRoute;
- (void)handleReceivedByte:(UInt8)byte withParity:(BOOL)parityGood atTimestamp:(double)timestamp;
- (void)sendFloJackConnectedStatusToDelegate:(BOOL)isFloJackConnected;
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
@synthesize outputAmplitude = _outputAmplitude;

#pragma mark - NFC Service Audio Sessions and Callbacks (C)

/**
 floJackAudioSessionInterruptionListener()
 Invoked when an audio interruption in iOS begins or ends.
 
 @param inClientData            Data that you specified in the inClientData parameter of the AudioSessionInitialize function. Can be NULL.
 @param inInterruptionState     A constant that indicates whether the interruption has just started or just ended. See “Audio Session Interruption States.”
 
 @return void
 */
void floJackAudioSessionInterruptionListener(void   *inClientData,
                                             UInt32 inInterruption)
{
	printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
	
	FJNFCService *nfcService = (FJNFCService *) inClientData;
	
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
		AudioSessionSetActive(true);
		OSStatus status = AudioOutputUnitStart(nfcService->_remoteIOUnit);
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
        AudioOutputUnitStop(nfcService->_remoteIOUnit);
    }
}

/**
 floJackAudioSessionPropertyListener()
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
    
    FJNFCService *self = (FJNFCService *)inClientData;
    
    
    if (inID == kAudioSessionProperty_AudioRouteChange) {
		try {
            // if there was a route change, we need to dispose the current rio unit and create a new one
			XThrowIfError(AudioComponentInstanceDispose(self->_remoteIOUnit), "couldn't dispose remote i/o unit");
			SetupRemoteIO(self->_remoteIOUnit, self->_audioUnitRenderCallback, self->_remoteIOOutputFormat);
			
			UInt32 size = sizeof(self->_hwSampleRate);
			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &self->_hwSampleRate), "couldn't get new sample rate");
			XThrowIfError(AudioOutputUnitStart(self->_remoteIOUnit), "couldn't start unit");
            
            // send interbyte delay config message if FloJack reconnected
            NSString *currentRoute = [(NSDictionary *)inData objectForKey:@"OutputDeviceDidChange_NewRoute"];
            NSLog(@"Current Route: %@", currentRoute);
            if ([self isHeadsetPluggedInWithRoute:currentRoute]) {
                
                [self sendFloJackConnectedStatusToDelegate:true];
            }
            else {
                [self sendFloJackConnectedStatusToDelegate:false];
            }
		}
        catch (CAXException e) {
			char buf[256];
			fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		}
	}
}

/** 
 floJackAURenderCallback()
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
    FJNFCService *self = (FJNFCService *)inRefCon;
	OSStatus ossError = AudioUnitRender(self->_remoteIOUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	
    // Bail out on critical audio errors
    if (ossError) {
        printf("(PerformThru) AudioUnitRender Error:%d\n", (int)ossError);
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
        
        if (sample != lastSample && sample_avg_high > SAMPLE_NOISE_CEILING && sample_avg_low < SAMPLE_NOISE_FLOOR) {
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
                            LogDecoder(@"Bit %d value %ld diff %ld parity %d\n", bitNum, sample, diff, parityRx & 0x01);
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
							}
                            else {
								// Invalid byte			
                                LogError(@" -- StopBit: %ld UartByte 0x%x\n", sample, uartByte);
                                parityGood = false;
							}
                            
                            // Send bye to message handler
                            NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
                            [self handleReceivedByte:uartByte withParity:parityGood atTimestamp:CACurrentMediaTime()];
                            [autoreleasepool release];
                            
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
					self->_byteQueuedForTX = FALSE;
				}
                else {
					encoderState = NEXTBIT;
				}
			} //end: if (phaseEnc >= nextPhaseEnc)
			
			switch (encoderState) {
				case STARTBIT:
				{
					uartByteTx = self->_byteForTX;

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

- (id) init {
    // Register an input callback function with an audio unit.
    _audioUnitRenderCallback.inputProc = floJackAURenderCallback;
	_audioUnitRenderCallback.inputProcRefCon = self;
	
    // Initialize receive handler buffer
    _messageReceiveBuffer = [[NSMutableData alloc] initWithCapacity:MAX_MESSAGE_LENGTH];
    _messageLength = MAX_MESSAGE_LENGTH;
    _messageCRC = 0;
    
    // Init state flags
    _currentlySendingMessage = FALSE;
    _muteEnabled = FALSE;
    
    [self markCurrentMessageValidAtTime:0];
    
    _byteQueuedForTX = FALSE;
    
    // Assume non EU device
    [self setOutputAmplitudeNormal];
    
	try {
        //float volumeLevel = [[MPMusicPlayerController applicationMusicPlayer] volume];
        //[[MPMusicPlayerController applicationMusicPlayer] setVolume:1.0];
        //NSLog(@"Volume Level: %g", volumeLevel);
        
        // Logic high/low varies based on host device
        _logicOne = [self getLogicOneValueBasedOnDevice];
        _logicZero = [self getLogicZeroValueBasedOnDevice];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            XThrowIfError(AudioSessionInitialize(NULL, NULL, floJackAudioSessionInterruptionListener, self), "couldn't initialize audio session");

		
		// Initialize and configure the audio session
		XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n");
		
		UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "couldn't set audio category");
		XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, floJackAudioSessionPropertyListener, self), "couldn't set property listener");
		
		Float32 preferredBufferSize = .005;
		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize), "couldn't set i/o buffer duration");
		
		UInt32 size = sizeof(_hwSampleRate);
		XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &_hwSampleRate), "couldn't get hw sample rate");
		
		XThrowIfError(SetupRemoteIO(_remoteIOUnit, _audioUnitRenderCallback, _remoteIOOutputFormat), "couldn't setup remote i/o unit");
		
		_remoteIODCFilter = new DCRejectionFilter[_remoteIOOutputFormat.NumberChannels()];
		
		size = sizeof(_maxFPS);
		XThrowIfError(AudioUnitGetProperty(_remoteIOUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &_maxFPS, &size), "couldn't get the remote I/O unit's max frames per slice");
		
		XThrowIfError(AudioOutputUnitStart(_remoteIOUnit), "couldn't start remote i/o unit");
		
		size = sizeof(_remoteIOOutputFormat);
		XThrowIfError(AudioUnitGetProperty(_remoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &_remoteIOOutputFormat, &size), "couldn't get the remote I/O unit's output client format");
            
            // Perform other setup here...
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
    
    // Setup Grand Central Dispatch queue (thread pool)
    _backgroundQueue = dispatch_queue_create("com.flomio.flojack", NULL);
	return self;
}

/**
 getLogicOneValueBasedOnDevice()
 Get the Logic One value based on device type. 
 
 --Machine name directory--
  @"i386"      on the simulator
  @"iPod1,1"   on iPod Touch
  @"iPod2,1"   on iPod Touch Second Generation
  @"iPod3,1"   on iPod Touch Third Generation
  @"iPod4,1"   on iPod Touch Fourth Generation
  @"iPhone1,1" on iPhone
  @"iPhone1,2" on iPhone 3G
  @"iPhone2,1" on iPhone 3GS
  @"iPhone3,1" on iPhone 4
  @"iPhone4,1" on iPhone 4S
  @"iPad1,1"   on iPad
  @"iPad2,1"   on iPad 2
 
 @return UInt8    1 or 0 indicating logical one for this device
 */
-(UInt8) getLogicOneValueBasedOnDevice  {
    // Get the device model number from uname
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* machineName = [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
    
    UInt8	logicOneValue = 1;
    if([machineName caseInsensitiveCompare:@"iPad3,1"] == NSOrderedSame) {
        // iPad 3 WiFi
        logicOneValue = 1;
    }
    else if([machineName caseInsensitiveCompare:@"iPad3,2"] == NSOrderedSame) {
        // iPad 3 LTE
        logicOneValue = 1;
    }
    else if([machineName caseInsensitiveCompare:@"iPad2,1"] == NSOrderedSame) {
        // iPad 2
        logicOneValue = 1;
    }
    else if([machineName caseInsensitiveCompare:@"iPad2,4"] == NSOrderedSame) {
        // iPad 2
        logicOneValue = 1;
    }
    else if([machineName caseInsensitiveCompare:@"iPad1,1"] == NSOrderedSame) {
        // iPad
        logicOneValue = 1;
    }
    else if([machineName caseInsensitiveCompare:@"iPhone4,1"] == NSOrderedSame) {
        // iPhone 4s
        logicOneValue = 1;
    }
    else if([machineName caseInsensitiveCompare:@"iPhone3,1"] == NSOrderedSame) {
        // iPhone 4
        logicOneValue = 1;
    }    
    else if([machineName caseInsensitiveCompare:@"iPhone2,1"] == NSOrderedSame) {
        // iPhone 3GS
        logicOneValue = 0;
    }
    else if([machineName caseInsensitiveCompare:@"iPhone1,2"] == NSOrderedSame) {
        // iPhone 3G
        logicOneValue = 0;
    }
    else  {
        // everything else. this probably won't work
        logicOneValue = 1;       
    }
    
    return logicOneValue;
}

/**
 getLogicZeroValueBasedOnDevice()
 Get the logical zero value based on device type.
 
 @return UInt8    1 or 0 indicating logical one for this device
 */
-(UInt8) getLogicZeroValueBasedOnDevice  {
    // Return inverse of LogicOne value
    if ([self getLogicOneValueBasedOnDevice] == 1)
        return 0;
    else
        return 1;
}


/**
 getCommunicationConfigMessage()
 This message sets the maximum byte transfer rate the FloJack can use.
 
 --Machine name directory--
 @"i386"      on the simulator
 @"iPod1,1"   on iPod Touch
 @"iPod2,1"   on iPod Touch Second Generation
 @"iPod3,1"   on iPod Touch Third Generation
 @"iPod4,1"   on iPod Touch Fourth Generation
 @"iPhone1,1" on iPhone
 @"iPhone1,2" on iPhone 3G
 @"iPhone2,1" on iPhone 3GS
 @"iPhone3,1" on iPhone 4
 @"iPhone4,1" on iPhone 4S
 @"iPad1,1"   on iPad
 @"iPad2,1"   on iPad 2
 
 @return UInt8    1 or 0 indicating logical one for this device
 */
-(UInt8*) getCommunicationConfigMessage  {
    // Get the device model number from uname
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* machineName = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    
    UInt8*	inter_byte_delay_message;
    if([machineName caseInsensitiveCompare:@"iPad3,2"] == NSOrderedSame) {
        // iPad 3 LTE
        inter_byte_delay_message = (UInt8*) inter_byte_delay_ipad3_msg;
    }
    else if([machineName caseInsensitiveCompare:@"iPad2,1"] == NSOrderedSame) {
        // iPad 2 WiFi
        inter_byte_delay_message = (UInt8*) inter_byte_delay_ipad2_msg;
    }
    else if([machineName caseInsensitiveCompare:@"iPad2,4"] == NSOrderedSame) {
        // iPad 2 WiFi (re-released)
        inter_byte_delay_message = (UInt8*) inter_byte_delay_ipad2_msg;
    }
    else if([machineName caseInsensitiveCompare:@"iPhone4,1"] == NSOrderedSame) {
        // iPhone 4s
        inter_byte_delay_message = (UInt8*) inter_byte_delay_iphone4s_msg;
    }
    else if([machineName caseInsensitiveCompare:@"iPhone3,1"] == NSOrderedSame) {
        // iPhone 4
        inter_byte_delay_message = (UInt8*) inter_byte_delay_iphone4_msg;
    }
    else if([machineName caseInsensitiveCompare:@"iPhone1,2"] == NSOrderedSame) {
        // iPhone 3G
        inter_byte_delay_message = (UInt8*) inter_byte_delay_iphone3gs_msg;
    }
    else  {
        // everything else. this probably won't work
        inter_byte_delay_message = (UInt8*) inter_byte_delay_iphone3gs_msg;
    }
    
    return inter_byte_delay_message;
}




-(void)handleReceivedByte:(UInt8)byte withParity:(BOOL)parityGood atTimestamp:(double)timestamp {
    
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
            //TODO : plumb this issue up to delegate
            LogError(@"Timeout reached. Dumping previous buffer. \n_messageReceiveBuffer:%@ \n_messageReceiveBuffer.length:%d", [_messageReceiveBuffer fj_asHexString], _messageReceiveBuffer.length);
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

-(void)clearMessageBuffer {
    [_messageReceiveBuffer setLength:0];
    _messageLength  = MAX_MESSAGE_LENGTH;
    _messageCRC = 0;
}

-(void)markCurrentMessageCorruptAndClearBufferAtTime:(double)timestamp {
    [self markCurrentMessageCorruptAtTime:timestamp];
    [self clearMessageBuffer];
}

-(void)markCurrentMessageCorruptAtTime:(double)timestamp {
    _lastByteReceivedAtTime = timestamp;
    _messageValid = false;
}

-(void)markCurrentMessageValidAtTime:(double)timestamp {
    _lastByteReceivedAtTime = timestamp;
    _messageValid = true;
}

/*
 setOutputAmplitudeHigh()
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
 setOutputAmplitudeHigh()
 Used to initialize output amplitude to normal levels. 
 For use on non-EU devices with full 120 dBA audio outputs.
 
 @return void
 */
- (void)setOutputAmplitudeNormal {
    _outputAmplitude = (1<<24);
}

/*
 * Helper Functions
*/

/**
 isHeadsetPluggedIn()
 Check if a headset (3-conductor plug) is plugged in 
  -- Definitions --
  Receiver: "the small speaker you hold to your ear when on a phone call"
  Headset: A 3-conductor plug in the headset jack (Left, Right, Microphone + Ground).
  Headphones: A 2-conductor plug in the headset jack (Left, Right + Ground)
  Microphone: The iPhone's microphone (at the base of the unit)
  Speaker: The iPhone's "loud" speaker (at the base of the unit)

  -- Known values of route --
   "Headset"
   "Headphone"
   "Speaker"
   "SpeakerAndMicrophone"
   "HeadphonesAndMicrophone"
   "HeadsetInOut"  <-- Used for the FloJack
   "ReceiverAndMicrophone"
   "Lineout"
 
 @return boolean    Indicates if the FloJack is connected
 */
- (BOOL)isHeadsetPluggedIn {
    UInt32 routeSize = sizeof(CFDictionaryRef);
    CFDictionaryRef reouteChange;
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRouteChange,
                                              &routeSize,
                                              &reouteChange);
    
    if (!error && (reouteChange != NULL)) {
        NSDictionary *audioRouteChangeDict = (NSDictionary *)reouteChange;
        NSString *currentRoute = [audioRouteChangeDict objectForKey:@"OutputDeviceDidChange_NewRoute"];
        return [self isHeadsetPluggedInWithRoute:currentRoute];
    }    
    return NO;
}

/**
 isHeadsetPluggedInWithRoute()
 Check if a headset (3-conductor plug) is plugged in
 
 @param currentRoute         NSString the new audio route
 
 @return boolean    Indicates if the FloJack is connected
 */
- (BOOL)isHeadsetPluggedInWithRoute:(NSString *)currentRoute {
    if (currentRoute != nil) {
        if ([currentRoute isEqualToString:@"HeadsetInOut"]) {
            return true;
        }
    }
    return false;
}

/**
 send()
 Queues up and sends a ingle byte across the audio line.
 
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
 sendByteToHost()
 Send one byte across the audio jack to the FloJack.
 
 @param theByte             The byte to be sent
 
 @return void
 */
- (void)sendByteToHost:(UInt8)theByte {
    // Keep transmitting the message until it's sent on the line
    while ([self send:theByte]);
}

/**
 sendMessageToHost()
 Send a message to the FloJack device. Message definitions can be found in device spec.
 
 @param message        Byte array representing a FloJack message {opcode, length, ..., CRC}

 @return void
 */
- (void)sendMessageToHost:(UInt8[])theMessage {
    [self sendMessageToHost:theMessage withLength:theMessage[FLOJACK_MESSAGE_LENGTH_POSITION]];
}


/**
 sendMessageToHost()
 Send a message to the FloJack device. Message definitions can be found in device spec.
 
 @param message        Byte array representing a FloJack message {opcode, length, ..., CRC}
 @param messageSize    Length of the message
 
 @return void
 */
- (void)sendMessageToHost:(UInt8[])theMessage withLength:(int)messageLength {
    _currentlySendingMessage = TRUE;
    
    for(int i=0; i<messageLength; i++) {
        LogInfo(@"sendMessageToHost item: 0x%x", theMessage[i]);
        [self sendByteToHost:theMessage[i]];
    }
    
    // Give the last byte time to transmit
    [NSThread sleepForTimeInterval:.025];
    _currentlySendingMessage = FALSE;
}


/**
 sendMutableArrayMessageToHost()
 Send a message to the FloJack device. Message definitions can be found in device spec.
 
 @param message        Byte array representing a FloJack message {opcode, length, ..., CRC}
 
 @return void
 */
- (void)sendMutableArrayMessageToHost:(NSMutableArray*)message {
    // error checking
    if (message == nil || [message count] == 0) {
        LogError(@"sendMutableArrayMessageToHost: Empty array");
        return;
    }
    else if ([message count] != [[message objectAtIndex:FLOJACK_MESSAGE_LENGTH_POSITION] unsignedCharValue]
             || [message count] > MAX_MESSAGE_LENGTH
             || [message count] < MIN_MESSAGE_LENGTH) {
        LogError(@"sendMutableArrayMessageToHost: Message length is corrput");
        return;
    }
    
    _currentlySendingMessage = TRUE;
    for(NSNumber *messageByte in message)
    {
        UInt8 byte = [messageByte unsignedCharValue];
        
        LogInfo(@"sendMessageToHost item: 0x%x", byte);
        [self sendByteToHost:byte];
    }
    
    // Give the last byte time to transmit
    [NSThread sleepForTimeInterval:.025];
    _currentlySendingMessage = FALSE;
}

// Send messsage bytes to the accessory
- (void)sendByteToHost:(UInt8)theByte {
    // Keep transmitting the message until it's sent on the line
    while ([self send:theByte]);

}

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

- (void)dealloc
{
	delete[] _remoteIODCFilter;
    dispatch_release(_backgroundQueue);
	[super dealloc];
}

#pragma mark Utilities for pushing bytes around

/**
 calculateCRCForMessage()
 Calculate the CRC for the given byte array
 
 @param message             Byte array representing a FloJack message {opcode, length, ...}. 
                                Does not include CRC byte.
 @param messageLength       Length of the FloJack message
 
 @return void
 */
- (UInt8)calculateCRCForMessage:(UInt8[])theMessage withLength:(int)messageLength
{
    UInt8 crc=0;
    for (int i=0; i<messageLength; i++)
    {
        crc ^= theMessage[i];
    }
    return crc;    
}

/**
 verifyCRCForMessage()
 Ensure this message's CRC is correct
 
 @param message             Byte array representing a FloJack message {opcode, length, ..., CRC}s
 
 @return void
 */
- (BOOL)verifyCRCForMessage:(UInt8[])theMessage
{
    UInt8 crc=0;
    UInt8 len=theMessage[FLOJACK_MESSAGE_LENGTH_POSITION];
    for (int i=0; i<(len-1); i++)
    {
        crc ^= theMessage[i];
    }
    LogInfo(@"CRC should be: 0x%02hhx and is: 0x%02hhx", (unsigned char) theMessage[len-1], (unsigned char) crc);
    return (crc == theMessage[len-1]);
}

@end
