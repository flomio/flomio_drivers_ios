//
//  FJNFCAdapter.h
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FJMessage.h"
#import "FJNFCService.h"
#import "FJNFCTag.h"
#import "Logging.h"
#import "FloBLEUart.h"


@protocol FJNFCAdapterDelegate;

@interface FJNFCAdapter : NSObject<FloBLEUartDelegate,FJNFCServiceDelegate>
{
    ledStatus_t ledMode;
}

@property (nonatomic, strong) id <FJNFCAdapterDelegate>	 delegate;
@property (nonatomic) BOOL                               pollFor14443aTags;
@property (nonatomic) BOOL                               pollFor15693Tags;
@property (nonatomic) BOOL                               pollForFelicaTags;
@property (nonatomic) BOOL                               standaloneMode;

// Set the tag polling rate in milliseconds. Value must be in range [0, 6375] and an increment of 25.
@property (nonatomic) NSInteger                          pollPeriod;


- (id)init;
- (void)initializeFloJackDevice;
//- (BOOL)isFloJackPluggedIn;
- (void)getFirmwareVersion;
- (void)getHardwareVersion;
- (void)getSnifferThresh;
- (void)getSnifferCalib;
- (void)setModeReadTagUID;
- (void)setModeReadTagUIDAndNDEF;
- (void)setModeReadTagData;
- (void)setModeWriteTagWithNdefMessage:(FJNDEFMessage *)theNDEFMessage;
- (void)setModeWriteTagWithPreviousNdefMessage;
- (void)sendMessageDataToHost:(NSData *)data;
- (void)sendMessageToHost:(FJMessage *)theMessage;
- (void)sendRawMessageToHost:(UInt8[])theMessage;
- (void)setIncrementSnifferThreshold:(UInt16)incrementAmount;
- (void)setDecrementSnifferThreshold:(UInt16)decrementAmount;
- (void)sendResetSnifferThreshold;  // method for last Sniffer Threshold command (no argument)
- (void)setMaxSnifferThreshold:(UInt16)maxThreshold;
- (void)setLedMode:(UInt16)ledMode;
@end

#pragma mark - NFC Adapter Protocol

@protocol FJNFCAdapterDelegate<NSObject>
 @required
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didScanTag:(FJNFCTag *)theNfcTag;
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didWriteTagAndStatusWas:(NSInteger)statusCode;
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didHaveStatus:(NSInteger)statusCode;
 @optional
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveFirmwareVersion:(NSString *)theVersionNumber;
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveHardwareVersion:(NSString *)theVersionNumber;
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveSnifferThresh:(NSString *)theSnifferValue;
  - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveSnifferCalib:(NSString *)theCalibValues;
@end
