//
//  AppDelegate.m
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import "AppDelegate.h"
#import "TagReadWriteViewController.h"
//#import "OadScreenViewController.h"
#import "FloBLEReader.h"

@interface AppDelegate ()
{
    //    FJAudioPlayer       *_fjAudioPlayer;
    NSString            *_scanSoundPath;
    TagReadWriteViewController *tagReadWriteViewController;
//    OadScreenViewController *oadScreenViewController;
    UINavigationController *navigationController;
}
@property (strong, nonatomic) TagReadWriteViewController *tagReadWriteViewController;
//@property (strong, nonatomic) OadScreenViewController *oadScreenViewController;
@property (strong, nonatomic) UINavigationController *navigationController;

@end

@implementation AppDelegate {
    CLLocationManager *_locationManager;
}

@synthesize floReaderManager;
@synthesize window;
@synthesize oadFile;
@synthesize tagReadWriteViewController;
//@synthesize oadScreenViewController;
@synthesize navigationController;


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

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        tagReadWriteViewController = [[TagReadWriteViewController alloc] initWithNibName:@"TagReadWriteViewController~iphone" bundle:nil];
    } else {
        tagReadWriteViewController = [[TagReadWriteViewController alloc] initWithNibName:@"TagReadWriteViewController" bundle:nil];
    }
/*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        oadScreenViewController = [[OadScreenViewController alloc] initWithNibName:@"OadScreenViewController" bundle:nil];
    } else {
        oadScreenViewController = [[OadScreenViewController alloc] initWithNibName:@"OadScreenViewController" bundle:nil];
    }
*/
    navigationController = [[UINavigationController alloc]initWithRootViewController:tagReadWriteViewController];
    
//    self.window.rootViewController = tagReadWriteViewController;
//    self.window.rootViewController = oadScreenViewController;
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    oadFile = [[OadFile alloc]initWithDelegate:self];
//    oadFile = [[OadFile alloc]init];

    
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
        notification.alertBody = @"FloBLE is in range";
    }
    else if(state == CLRegionStateOutside)
    {
        notification.alertBody = @"FloBLE is out of range";
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

- (void)didReceivedImageBlockTransferCharacteristic:(NSData*)imageBlockCharacteristic
{
    [oadFile receivedImageBlockTransferCharacteristic:imageBlockCharacteristic];
}

- (void)didReceivedImageIdentifyCharacteristic:(NSData*)imageBlockCharacteristic
{
    [oadFile receivedImageIdentifyCharacteristic:imageBlockCharacteristic];
    NSLog(@"didReceivedImageIdentifyCharacteristic");
    if (self.tagReadWriteViewController.oadScreenViewController)[self.tagReadWriteViewController.oadScreenViewController updateCurrentImageType:(imageType)0];
}

- (void)didReceiveServiceFirmwareVersion:(NSString *)theVersionNumber
{
    NSLog(@"AppDelegate didReceiveServiceFirmwareVersion %@",theVersionNumber);
    [oadFile setCurrentFirmwareVersion:theVersionNumber];
}

- (void)playTagReadSound
{
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:_scanSoundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didScanTag:(FJNFCTag *)theNfcTag {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = [NSString stringWithFormat:@"Tag detected: %@",[theNfcTag.uid fj_asHexString]];
    
    //    [_fjAudioPlayer playSoundWithPath:_scanSoundPath];visibleViewController
    
//    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didScanTag:)]) {
//        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didScanTag:theNfcTag];
//    }
    [self.tagReadWriteViewController floReaderManager:theFloReaderManager didScanTag:theNfcTag];
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
//    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didHaveStatus:)]) {
//        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didHaveStatus:statusCode];
//    }
    [self.tagReadWriteViewController floReaderManager:theFloReaderManager didHaveStatus:statusCode];

}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didWriteTagAndStatusWas:(NSInteger)statusCode {
//    [_fjAudioPlayer playSoundWithPath:_scanSoundPath];
    
//    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didWriteTagAndStatusWas:)]) {
//        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didWriteTagAndStatusWas:statusCode];
//    }
    
    [self.tagReadWriteViewController floReaderManager:theFloReaderManager didWriteTagAndStatusWas:statusCode];

}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didReceiveFirmwareVersion:(NSString*)theVersionNumber {
//    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didReceiveFirmwareVersion:)]) {
//        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didReceiveFirmwareVersion:theVersionNumber];
//    }
    [self.tagReadWriteViewController floReaderManager:theFloReaderManager didReceiveFirmwareVersion:theVersionNumber];

}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didReceiveHardwareVersion:(NSString*)theVersionNumber; {
//    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didReceiveHardwareVersion:)]) {
 //       [(id)self.window.rootViewController floReaderManager:theFloReaderManager didReceiveHardwareVersion:theVersionNumber];
//    }
    [self.tagReadWriteViewController floReaderManager:theFloReaderManager didReceiveHardwareVersion:theVersionNumber];

}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didReceiveSnifferThresh:(NSString *)theSnifferValue; {
//    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didReceiveSnifferThresh:)]) {
//        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didReceiveSnifferThresh:theSnifferValue];
//    }
    [self.tagReadWriteViewController floReaderManager:theFloReaderManager didReceiveSnifferThresh:theSnifferValue];

}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didReceiveSnifferCalib:(NSString *)theCalibValues; {
//    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didReceiveSnifferCalib:)]) {
//        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didReceiveSnifferCalib:theCalibValues];
//    }
    [self.tagReadWriteViewController floReaderManager:theFloReaderManager didReceiveSnifferCalib:theCalibValues];

}

- (void)floReaderManager:(FLOReaderManager *)theFloReaderManager didReceiveWristbandState:(NSString*)theState; {
    [self.tagReadWriteViewController floReaderManager:theFloReaderManager didReceiveWristbandState:theState];
}

#pragma mark - OadScreenViewController delegate

- (void)updateButtonPress
{
    bool success = NO;
    //    NSData* block = [oadFile getOadHeaderBlock];
    //   [self.floReaderManager.nfcService writeBlockToOadImageIdentifyWithOutResponse:&block.bytes[0] ofLength:sizeof(oad_img_hdr_t)];
    
//    unsigned char data = 0x01;
//    NSData* block = [NSData dataWithBytes:&data length:1];
    //    [self.floReaderManager.nfcService writeBlockToOadImageIdentifyWithOutResponse:&block.bytes[0] ofLength:1];
    //    [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
    
    success = [oadFile initiateUpload];
    if(success)
    {

        [oadFile establishUpload];
    }
    else
    {
        //flag an error and abort
    }
    
    //    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(oadTimerTick:) userInfo:nil repeats:NO];
    //    NSLog(@"::AppDelegate updateButtonPress %@",block);
    
}


#pragma mark - OadFile Delegate Functions

- (void)writeBlockToOadImageIdentify:(NSData*)block
{
    UInt8* blockPtr = (UInt8*)block.bytes;
    [self.floReaderManager.nfcService writeBlockToOadImageIdentifyWithOutResponse:blockPtr ofLength:block.length];
    NSLog(@"writeBlockToOadImageIdentify");
}

- (void)writeBlockToOadBlockTransfer:(NSData*)block
{
    UInt8* blockPtr = (UInt8*)block.bytes;
    [self.floReaderManager.nfcService writeBlockToOadImageBlockTransferWithOutResponse:blockPtr ofLength:block.length];
//    NSLog(@"writeBlockToOadBlockTransfer %@",block);
}

- (void)endOfUploadNotification
{
    NSLog(@"Upload Complete, must reconnect");
    [self.tagReadWriteViewController.oadScreenViewController endOfUpdate];
}

- (void)cancelationOfUploadNotification
{
    NSLog(@"Upload Canceled");
}

- (void)connectionLostNotification
{
    NSLog(@"Lost connection");

}


@end
