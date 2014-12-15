//
//  HiJack.h
//  
//
//  Originally created by Thomas Schmid on 8/4/11.
//  Licensed under the New BSD Licensce (http://opensource.org/licenses/BSD-3-Clause)
//

//#import <dispatch/dispatch.h>
#import <sys/utsname.h>

#import <Foundation/Foundation.h>
#import "NFCMessage.h"
#import "NSData+FJStringDisplay.h"
#import "Logging.h"

@protocol FLOReaderDelegate;

@interface FLOReader : NSObject
{
//    BOOL deviceConnected;
}

@property id <FLOReaderDelegate>	delegate;
//@property (nonatomic) dispatch_semaphore_t messageTXLock;
@property (readonly) BOOL	isDeviceConnected;
@property (assign) BOOL deviceConnected;

- (id)init;
- (void)sendByteToHost:(UInt8)theByte;
- (BOOL)sendMessageDataToHost:(NSData *)messageData;
- (void)handleReceivedByte:(UInt8)byte withParity:(BOOL)parityGood atTimestamp:(double)timestamp;

@end

#pragma mark - NFC Service Protocol

@protocol FLOReaderDelegate<NSObject>
 @required
  - (void)nfcService:(FLOReader *)nfcService didHaveError:(NSInteger)errorCode;
  - (void)nfcService:(FLOReader *)nfcService didReceiveMessage:(NSData *)theMessage;
@end
