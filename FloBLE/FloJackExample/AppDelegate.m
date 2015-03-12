//
//  AppDelegate.m
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import "AppDelegate.h"
#import "TagReadWriteViewController.h"
#import "FloBLEReader.h"

@implementation AppDelegate {
//    FJAudioPlayer       *_fjAudioPlayer;
    NSString            *_scanSoundPath;
    CLLocationManager *_locationManager;
}

@synthesize floReaderManager;
@synthesize window;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Note: CoreLocation requires the iBeacon profile to be configured in the FloBLE. This will not work without it
    // This location manager will be used to notify the user of region state transitions.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"A495FF10-C5B1-4B44-B512-1370F02D74DE"] identifier:@"com.flomio.FloBLE"]; //Update with iBeacon UUID (difference from FloBLE service UUID
    if(region)
    {
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        region.notifyEntryStateOnDisplay = NO;
        
        [_locationManager startMonitoringForRegion:region];
    }

    // Register for local notifications in iOS 8+.
    #ifdef __IPHONE_8_0
        UIUserNotificationType notificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil]];
    #endif

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.floReaderManager = [[FLOReaderManager alloc] init];
    [self.floReaderManager setDelegate:self];
    
    _scanSoundPath = [[NSBundle mainBundle] pathForResource:@"scan_sound" ofType:@"mp3"];

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

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    // Note: CoreLocation requires the iBeacon profile to be configured in the FloBLE. This will not work without it
    // A user can transition in or out of a region while the application is not running.
    // When this happens CoreLocation will launch the application momentarily, call this delegate method
    // and we will let the user know via a local notification.
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if(state == CLRegionStateInside)
    {
        notification.alertBody = @"Welcome to McDonalds";
    }
    else if(state == CLRegionStateOutside)
    {
        notification.alertBody = @"Thanks for visiting McDonalds";
    }
    else
    {
        return;
    }
    
    // If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
    // If its not, iOS will display the notification to the user.
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // If the application is in the foreground, we will notify the user of the region's state via an alert.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - FLOReaderManagerDelegate
- (void)playTagReadSound
{
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:_scanSoundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didScanTag:(FJNFCTag *)theNfcTag {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = [NSString stringWithFormat:@"Welcome to McDonald's: %@",[theNfcTag.uid fj_asHexString]];
    
    // Play Tag Read Sound when app is in the foreground (ie when notifications don't sound)
    [self playTagReadSound];
    
    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didScanTag:)]) {
        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didScanTag:theNfcTag];
    }

    // If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
    // If its not, iOS will display the notification to the user.
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
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
