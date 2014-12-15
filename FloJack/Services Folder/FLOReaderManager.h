//
//  FLOReaderManager.h
//  
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NFCMessage.h"
#import "FLOReader.h"
#import "FLOTag.h"
#import "Logging.h"
#import "FloBLEReader.h"


@protocol FLOReaderManagerDelegate;

@interface FLOReaderManager : NSObject<FloBLEReaderDelegate,FLOReaderDelegate>
{
    ledStatus_t ledMode;
}

@property (nonatomic, strong) id <FLOReaderManagerDelegate>	 delegate;
@property (nonatomic) BOOL                               pollFor14443aTags;
@property (nonatomic) BOOL                               pollFor15693Tags;
@property (nonatomic) BOOL                               pollForFelicaTags;
@property (nonatomic) BOOL                               standaloneMode;

// Set the tag polling rate in milliseconds. Value must be in range [0, 6375] and an increment of 25.
@property (nonatomic) NSInteger                          pollPeriod;


- (id)init;
- (void)getFirmwareVersion;
- (void)getHardwareVersion;
- (void)getSnifferThresh;
- (void)getSnifferCalib;
- (void)setModeReadTagUID;
- (void)setModeReadTagUIDAndNDEF;
- (void)setModeReadTagData;
- (void)setModeWriteTagWithNdefMessage:(NDEFMessage *)theNDEFMessage;
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

@protocol FLOReaderManagerDelegate<NSObject>
 @required
  - (void)floReaderManager:(FLOReaderManager *)floReaderManager didScanTag:(FJNFCTag *)theNfcTag;
  - (void)floReaderManager:(FLOReaderManager *)floReaderManager didWriteTagAndStatusWas:(NSInteger)statusCode;
  - (void)floReaderManager:(FLOReaderManager *)floReaderManager didHaveStatus:(NSInteger)statusCode;
 @optional
  - (void)floReaderManager:(FLOReaderManager *)floReaderManager didReceiveFirmwareVersion:(NSString *)theVersionNumber;
  - (void)floReaderManager:(FLOReaderManager *)floReaderManager didReceiveHardwareVersion:(NSString *)theVersionNumber;
  - (void)floReaderManager:(FLOReaderManager *)floReaderManager didReceiveSnifferThresh:(NSString *)theSnifferValue;
  - (void)floReaderManager:(FLOReaderManager *)floReaderManager didReceiveSnifferCalib:(NSString *)theCalibValues;
@end
