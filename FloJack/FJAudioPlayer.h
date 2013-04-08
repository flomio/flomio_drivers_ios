//
//  FJUtilities.h
//  FloJack
//
//  Created by John Bullard on 4/5/13.
//  Copyright (c) 2013 John Bullard. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>
#import "FJNFCService.h"
#import "FJAudioSessionHelper.h"

@interface FJAudioPlayer : NSObject <AVAudioPlayerDelegate>

@property (strong, readonly) FJNFCService *fjNfcService;
@property (nonatomic) AVAudioPlayer *audioPlayer;

-(id)initWithNFCService:(FJNFCService *)fjNfcService;
-(BOOL)playSoundWithPath:(NSString *)path;

// AVAudioPlayerDelegate Protocol
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

@end
