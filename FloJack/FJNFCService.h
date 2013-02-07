//
//  HiJack.h
//  FloJack
//
//  Originally created by Thomas Schmid on 8/4/11.
//  Licensed under the New BSD Licensce (http://opensource.org/licenses/BSD-3-Clause)
//

#import <AudioToolbox/AudioToolbox.h>
#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CAAnimation.h>
#import <sys/utsname.h>
#import "AudioUnit/AudioUnit.h"
#import "aurio_helper.h"
#import "CAStreamBasicDescription.h"
#import "CAXException.h"
#import "FJMessage.h"
#import "Logging.h"

@protocol FJNFCServiceDelegate;

@interface FJNFCService : NSObject 

@property (nonatomic, assign) id <FJNFCServiceDelegate>	 delegate;

- (id)init;
- (UInt8 *)getCommunicationConfigMessage;
- (BOOL)isHeadsetPluggedIn;
- (BOOL)isHeadsetPluggedInWithRoute:(NSString *)currentRoute;
- (void)sendByteToHost:(UInt8)theByte;
- (void)sendMessageToHost:(UInt8[])theMessage;
- (void)sendMessageToHost:(UInt8[])theMessage withLength:(int)messageLength;
- (void)setDelegate:(id<FJNFCServiceDelegate>)delegate;

@end

#pragma mark - NFC Service Protocol

@protocol FJNFCServiceDelegate<NSObject>
 @required
  - (void)nfcService:(FJNFCService *)nfcService didReceiveMessage:(NSData *)theMessage;
  - (void)nfcServiceDidReceiveFloJack:(FJNFCService *)nfcService connectedStatus:(BOOL)isFloJackConnected;

@end
