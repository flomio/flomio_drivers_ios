//
//  HiJack.h
//  FloJack
//
//  Originally created by Thomas Schmid on 8/4/11.
//  Licensed under the New BSD Licensce (http://opensource.org/licenses/BSD-3-Clause)
//

//#import <dispatch/dispatch.h>
#import <sys/utsname.h>

#import <Foundation/Foundation.h>
#import "FJMessage.h"
#import "NSData+FJStringDisplay.h"
#import "Logging.h"

@protocol FJNFCServiceDelegate;

@interface FJNFCService : NSObject
{
//    BOOL deviceConnected;
}

@property id <FJNFCServiceDelegate>	delegate;
//@property (nonatomic) dispatch_semaphore_t messageTXLock;
@property (readonly) BOOL	floJackConnected;
@property (assign) BOOL deviceConnected;

- (id)init;
- (void)sendByteToHost:(UInt8)theByte;
- (BOOL)sendMessageDataToHost:(NSData *)messageData;
- (void)handleReceivedByte:(UInt8)byte withParity:(BOOL)parityGood atTimestamp:(double)timestamp;

@end

#pragma mark - NFC Service Protocol

@protocol FJNFCServiceDelegate<NSObject>
 @required
  - (void)nfcService:(FJNFCService *)nfcService didHaveError:(NSInteger)errorCode;
  - (void)nfcService:(FJNFCService *)nfcService didReceiveMessage:(NSData *)theMessage;
  - (void)nfcServiceDidReceiveFloJack:(FJNFCService *)nfcService connectedStatus:(BOOL)isFloJackConnected;
@end
