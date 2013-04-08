//
//  FJUtilities.m
//  FloJack
//
//  Created by John Bullard on 4/5/13.
//  Copyright (c) 2013 John Bullard. All rights reserved.
//

#import "FJAudioPlayer.h"

@implementation FJAudioPlayer
@synthesize audioPlayer         = _audioPlayer;
@synthesize fjNfcService        = _fjNfcService;

/**
 Designated initializer. FJNFCService object is needed to lock/release audio TX semaphores.
 
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
        [_fjNfcService enableDeviceSpeaker];
        
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


#pragma mark - AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_fjNfcService disableDeviceSpeaker];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [_fjNfcService disableDeviceSpeaker];
}

@end
