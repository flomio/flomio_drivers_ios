//
//  com_flomio_flobleAppDelegate.m
//  FloBleExample
//
//  Created by Richard Grundy on 1/15/14.
//  Copyright (c) 2014 Flomio, Inc. All rights reserved.
//

#import "com_flomio_flobleAppDelegate.h"
#import "TagReadWriteViewController.h"

@implementation com_flomio_flobleAppDelegate {
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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