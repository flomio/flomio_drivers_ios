//
//  AppDelegate.m
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import "AppDelegate.h"
#import "TagReadWriteViewController.h"

@implementation AppDelegate {
//    FJAudioPlayer       *_fjAudioPlayer;
    NSString            *_scanSoundPath;
}

@synthesize floReaderManager;
@synthesize window;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.floReaderManager = [[FLOReaderManager alloc] init];
    [self.floReaderManager setDelegate:self];
    
    _scanSoundPath = [[NSBundle mainBundle] pathForResource:@"scan_sound" ofType:@"mp3"];
    //    _scanSound = [[NSSound alloc]initWithContentsOfFile:_scanSoundPath byReference:YES];

    TagReadWriteViewController *tagReadWriteViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        tagReadWriteViewController = [[TagReadWriteViewController alloc] initWithNibName:@"TagReadWriteViewController~iphone" bundle:nil];
    } else {
        tagReadWriteViewController = [[TagReadWriteViewController alloc] initWithNibName:@"TagReadWriteViewController" bundle:nil];
    }
    
    self.window.rootViewController = tagReadWriteViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

#pragma mark - FLOReaderManagerDelegate
- (void)playTagReadSound
{
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:_scanSoundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didScanTag:(FJNFCTag *)theNfcTag {
// Play Tag Read Sound
    [self playTagReadSound];
    
    //    [_fjAudioPlayer playSoundWithPath:_scanSoundPath];
    
    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didScanTag:)]) {
        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didScanTag:theNfcTag];
    }
}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didHaveStatus:(NSInteger)statusCode {
    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didHaveStatus:)]) {
        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didHaveStatus:statusCode];
    }
}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didWriteTagAndStatusWas:(NSInteger)statusCode {
//    [_fjAudioPlayer playSoundWithPath:_scanSoundPath];
    
    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didWriteTagAndStatusWas:)]) {
        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didWriteTagAndStatusWas:statusCode];
    }
}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didReceiveFirmwareVersion:(NSString*)theVersionNumber {
    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didReceiveFirmwareVersion:)]) {
        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didReceiveFirmwareVersion:theVersionNumber];
    }
}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didReceiveHardwareVersion:(NSString*)theVersionNumber; {
    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didReceiveHardwareVersion:)]) {
        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didReceiveHardwareVersion:theVersionNumber];
    }
}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didReceiveSnifferThresh:(NSString *)theSnifferValue; {
    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didReceiveSnifferThresh:)]) {
        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didReceiveSnifferThresh:theSnifferValue];
    }
}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didReceiveSnifferCalib:(NSString *)theCalibValues; {
    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didReceiveSnifferCalib:)]) {
        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didReceiveSnifferCalib:theCalibValues];
    }
}
@end
