//
//  FJNFCAdapter.h
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <Foundation/Foundation.h>
#import "FJAudioPlayer.h"
#import "FJNDEFRecord.h"
#import "FJMessage.h"
#import "FJNFCService.h"
#import "FJNFCTag.h"
#import "Logging.h"

@protocol FJNFCAdapterDelegate;

@interface FJNFCAdapter : NSObject<FJNFCServiceDelegate>

@property (nonatomic, strong) id <FJNFCAdapterDelegate>	 delegate;
@property (nonatomic) BOOL                               deviceHasVolumeCap;
@property (nonatomic) BOOL                               pollFor14443aTags;
@property (nonatomic) BOOL                               pollFor15693Tags;
@property (nonatomic) BOOL                               pollForFelicaTags;

// Set the tag polling rate in milliseconds. Value must be in range [0, 6375] and an increment of 25.
@property (nonatomic) NSInteger                          pollPeriod;

- (id)init;
- (void)initializeFloJackDevice;
- (BOOL)isFloJackPluggedIn;
- (void)getFirmwareVersion;
- (FJAudioPlayer *)getFJAudioPlayer;
- (void)getHardwareVersion;
- (void)getSnifferThresh;
- (void)setModeReadTagUID;
- (void)setModeReadTagUIDAndNDEF;
- (void)setModeReadTagData;
- (void)setModeWriteTagWithNdefMessage:(FJNDEFMessage *)theNDEFMessage;
- (void)setModeWriteTagWithPreviousNdefMessage;
- (void)sendMessageDataToHost:(NSData *)data;
- (void)sendMessageToHost:(FJMessage *)theMessage;
- (void)sendRawMessageToHost:(UInt8[])theMessage;

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
@end
