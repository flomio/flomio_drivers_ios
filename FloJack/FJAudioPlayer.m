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
 
 @return BOOL indicates if execution was successful 
 */
-(BOOL)disableFloJackAudioComm {
    dispatch_semaphore_wait(self.fjNfcService.messageTXLock, DISPATCH_TIME_FOREVER);
    BOOL success = true;   
    
    NSError *sharedAudioSessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sharedAudioSessionError];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    OSStatus setPropertyRouteError  = 0;
    setPropertyRouteError = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    if (sharedAudioSessionError != nil || setPropertyRouteError != 0) {
        LogError("AudioSession Error(s): %@, %@", sharedAudioSessionError.localizedDescription, [FJAudioSessionHelper formatOSStatus:setPropertyRouteError]);
        dispatch_semaphore_signal(self.fjNfcService.messageTXLock);
        success = false;
    }    
    return success;
}

/**
 Enables FloJack audio line communication and switches route to HeadSetInOut.
 
 @return BOOL indicates if execution was successful 
 */
-(BOOL)enableFloJackAudioComm {
    BOOL success = true;
    
    NSError *sharedAudioSessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sharedAudioSessionError];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    OSStatus setPropertyRouteError  = 0;
    setPropertyRouteError = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    NSError *sharedAudioSessionSetActiveError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if (sharedAudioSessionError != nil || setPropertyRouteError != 0 || sharedAudioSessionSetActiveError != nil) {
        LogError("AudioSession Error(s): %@, %@, %@", sharedAudioSessionError.localizedDescription, [FJAudioSessionHelper formatOSStatus:setPropertyRouteError], sharedAudioSessionSetActiveError.localizedDescription);
        success = false;
    }    
    dispatch_semaphore_signal(self.fjNfcService.messageTXLock);
    return success;
}

#pragma mark - AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self enableFloJackAudioComm];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self enableFloJackAudioComm];
}

@end
