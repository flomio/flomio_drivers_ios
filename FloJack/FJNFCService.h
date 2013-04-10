//
//  HiJack.h
//  FloJack
//
//  Originally created by Thomas Schmid on 8/4/11.
//  Licensed under the New BSD Licensce (http://opensource.org/licenses/BSD-3-Clause)
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
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
#import "FJAudioSessionHelper.h"
#import "FJMessage.h"
#import "NSData+FJStringDisplay.h"
#import "Logging.h"

@protocol FJNFCServiceDelegate;

@interface FJNFCService : NSObject 

@property id <FJNFCServiceDelegate>	delegate;
@property (nonatomic) dispatch_semaphore_t messageTXLock;
@property (readonly) BOOL	floJackConnected;
@property (readonly) UInt32	outputAmplitude;

- (id)init;
- (BOOL)checkIfVolumeLevelMaxAndNotifyDelegate;
- (BOOL)disableDeviceSpeakerPlayback;
- (BOOL)enableDeviceSpeakerPlayback;
- (void)sendByteToHost:(UInt8)theByte;
- (void)sendMessageDataToHost:(NSData *)messageData;
- (void)setOutputAmplitudeHigh;
- (void)setOutputAmplitudeNormal;

+ (UInt8)getDeviceInterByteDelay;
+ (UInt8)getDeviceLogicOneValue;
+ (UInt8)getDeviceLogicZeroValue;

@end

#pragma mark - NFC Service Protocol

@protocol FJNFCServiceDelegate<NSObject>
 @required
  - (void)nfcService:(FJNFCService *)nfcService didHaveError:(NSInteger)errorCode;
  - (void)nfcService:(FJNFCService *)nfcService didReceiveMessage:(NSData *)theMessage;
  - (void)nfcServiceDidReceiveFloJack:(FJNFCService *)nfcService connectedStatus:(BOOL)isFloJackConnected;
@end
