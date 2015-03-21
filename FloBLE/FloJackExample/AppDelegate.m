//
//  AppDelegate.m
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import "AppDelegate.h"
#import "TagReadWriteViewController.h"
#import "OadScreenViewController.h"

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
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.floReaderManager = [[FLOReaderManager alloc] init];
    [self.floReaderManager setDelegate:self];
    
    _scanSoundPath = [[NSBundle mainBundle] pathForResource:@"scan_sound" ofType:@"mp3"];
    //    _scanSound = [[NSSound alloc]initWithContentsOfFile:_scanSoundPath byReference:YES];

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
// Play Tag Read Sound
    [self playTagReadSound];
    
    //    [_fjAudioPlayer playSoundWithPath:_scanSoundPath];visibleViewController
    
//    if ([self.window.rootViewController respondsToSelector:@selector(floReaderManager: didScanTag:)]) {
//        [(id)self.window.rootViewController floReaderManager:theFloReaderManager didScanTag:theNfcTag];
//    }
    [self.tagReadWriteViewController floReaderManager:theFloReaderManager didScanTag:theNfcTag];
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
