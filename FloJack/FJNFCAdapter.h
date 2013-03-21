//
//  FJNFCAdapter.h
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <Foundation/Foundation.h>
#import "FJNDEFRecord.h"
#import "FJMessage.h"
#import "FJNFCService.h"
#import "FJNFCTag.h"
#import "Logging.h"

@protocol FJNFCAdapterDelegate;

@interface FJNFCAdapter : NSObject<FJNFCServiceDelegate>

@property id <FJNFCAdapterDelegate>	 delegate;

- (id)init;
- (void)setDelegate:(id <FJNFCAdapterDelegate>) delegate;
- (void)sendMessageToHost:(FJMessage *)theMessage;
- (void)sendRawMessageToHost:(UInt8[])theMessage;
- (void)writeTagWithNdefMessage:(FJNDEFMessage *)theNDEFMessage;
- (void)writeTagWithPreviousNdefMessage;

// temporarily used for Type2 Write testing
- (void)operationModeWriteDataTestPrevious;

// how many of these do we want to expose?
- (void)disable14443AProtocol;
- (void)disable14443BProtocol;
- (void)disable15693Protocol;
- (void)disableFelicaProtocol;
- (void)disableMessageAcks;
- (void)disableStandaloneMode;
- (void)disableTagPolling;
- (void)dumpAndClearTagLog;
- (void)enable14443AProtocol;
- (void)enable14443BProtocol;
- (void)enable15693Protocol;
- (void)enableFelicaProtocol;
- (void)enableMessageAcks;
- (void)enableStandaloneMode;
- (void)enableTagPolling;
- (void)getAllStatus;
- (void)getFirmwareVersion;
- (void)getHardwareVersion;
- (BOOL)isFloJackPluggedIn;
- (void)setPollingRateTo1000ms;
- (void)setPollingRateTo3000ms;
- (void)setStandaloneModeKeepAliveTimeToOneMinute;
- (void)setStandaloneModeKeepAliveTimeInfinite;
- (void)turnLedOn;
- (void)turnLedOff;
- (void)operationModeUID;
- (void)operationModeReadOnly;

@end

#pragma mark - NFC Adapter Protocol

@protocol FJNFCAdapterDelegate<NSObject>
 @required
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didScanTag:(FJNFCTag *)theNfcTag;
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didWriteTagAndStatusWas:(NSInteger)errorCode;
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didHaveStatus:(NSInteger)statusCode;
 @optional
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveFirmwareVersion:(NSString *)theVersionNumber;
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveHardwareVersion:(NSString *)theVersionNumber;
  - (void)nfcAdapterDidDetectFloJackConnected:(FJNFCAdapter *)nfcAdapter;
  - (void)nfcAdapterDidDetectFloJackDisconnected:(FJNFCAdapter *)nfcAdapter;
@end
