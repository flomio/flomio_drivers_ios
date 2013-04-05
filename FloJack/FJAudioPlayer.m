//
//  FJUtilities.m
//  FloJack
//
//  Created by John Bullard on 4/5/13.
//  Copyright (c) 2013 John Bullard. All rights reserved.
//

#import "FJAudioPlayer.h"


@implementation FJAudioPlayer
@synthesize audioPlayer = _audioPlayer;
@synthesize fjNfcService = _fjNfcService;

/**
 TODO
 
 @return 
 */
-(id)init {
    return [self initWithNFCService:nil];
}

/**
 TODO
 
 @return 
 */
-(id)initWithNFCService:(FJNFCService *)fjNfcService {
    self = [super init];
    if(self) {
        _fjNfcService = fjNfcService;
    }
    return self;
}

/**
 Plays sound through the external speaker temporarily then reverts back to HeadSetInOut
 for FloJack comm.
 
 @param NSString Sound file path
 @return BOOL  Was the sound played
 */
-(BOOL)playSoundWithPath:(NSString *)path
{
    BOOL soundPlayed;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        LogError(@"sound file not found: %@", path);
        soundPlayed = false;
    }
    else {
        [self disableFloJackAudioComm];
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        NSError *error;
        NSURL *url = [NSURL fileURLWithPath:path];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.numberOfLoops = 0;
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        
        if (self.audioPlayer != nil)
        {
            [self.audioPlayer play];
            soundPlayed = true;
        }
        else {
            soundPlayed = false;
        }
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
    return soundPlayed;
}

/**
 Disables FloJack audio line communication and switches route to external speaker.
 
 @return void
 */
-(void)disableFloJackAudioComm {
    dispatch_semaphore_wait(self.fjNfcService.messageTXLock, DISPATCH_TIME_FOREVER);
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    UInt32 allowMixing = true;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
}

/**
 Enables FloJack audio line communication and switches route to HeadSetInOut.
 
 @return void
 */
-(void)enableFloJackAudioComm {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    UInt32 allowMixing = true;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    dispatch_semaphore_signal(self.fjNfcService.messageTXLock);
}

#pragma mark - AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self enableFloJackAudioComm];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self enableFloJackAudioComm];
}

@end
