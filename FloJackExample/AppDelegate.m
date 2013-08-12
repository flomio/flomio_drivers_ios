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
    FJAudioPlayer       *_fjAudioPlayer;
    NSString            *_scanSoundPath;
}

@synthesize nfcAdapter;
@synthesize window;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.nfcAdapter = [[FJNFCAdapter alloc] init];
    [self.nfcAdapter setDelegate:self];
    
    _scanSoundPath = [[NSBundle mainBundle] pathForResource:@"scan_sound" ofType:@"mp3"];
    _fjAudioPlayer = [self.nfcAdapter getFJAudioPlayer];
    
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

#pragma mark - FJNFCAdapterDelegate

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didScanTag:(FJNFCTag *)theNfcTag {
    [_fjAudioPlayer playSoundWithPath:_scanSoundPath];
    
    if ([self.window.rootViewController respondsToSelector:@selector(nfcAdapter: didScanTag:)]) {
        [(id)self.window.rootViewController nfcAdapter:theNfcAdapter didScanTag:theNfcTag];        
    }
}

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didHaveStatus:(NSInteger)statusCode {
    if ([self.window.rootViewController respondsToSelector:@selector(nfcAdapter: didHaveStatus:)]) {
        [(id)self.window.rootViewController nfcAdapter:theNfcAdapter didHaveStatus:statusCode];
    }
}

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didWriteTagAndStatusWas:(NSInteger)statusCode {
    [_fjAudioPlayer playSoundWithPath:_scanSoundPath];
    
    if ([self.window.rootViewController respondsToSelector:@selector(nfcAdapter: didWriteTagAndStatusWas:)]) {
        [(id)self.window.rootViewController nfcAdapter:theNfcAdapter didWriteTagAndStatusWas:statusCode];
    }
}

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didReceiveFirmwareVersion:(NSString*)theVersionNumber {
    if ([self.window.rootViewController respondsToSelector:@selector(nfcAdapter: didReceiveFirmwareVersion:)]) {
        [(id)self.window.rootViewController nfcAdapter:theNfcAdapter didReceiveFirmwareVersion:theVersionNumber];
    }
}

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didReceiveHardwareVersion:(NSString*)theVersionNumber; {
    if ([self.window.rootViewController respondsToSelector:@selector(nfcAdapter: didReceiveHardwareVersion:)]) {
        [(id)self.window.rootViewController nfcAdapter:theNfcAdapter didReceiveHardwareVersion:theVersionNumber];
    }
}

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didReceiveSnifferThresh:(NSString *)theSnifferValue; {
    if ([self.window.rootViewController respondsToSelector:@selector(nfcAdapter: didReceiveSnifferThresh:)]) {
        [(id)self.window.rootViewController nfcAdapter:theNfcAdapter didReceiveSnifferThresh:theSnifferValue];
    }
}

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didReceiveSnifferCalib:(NSString *)theCalibValues; {
    if ([self.window.rootViewController respondsToSelector:@selector(nfcAdapter: didReceiveSnifferCalib:)]) {
        [(id)self.window.rootViewController nfcAdapter:theNfcAdapter didReceiveSnifferCalib:theCalibValues];
    }
}
@end
