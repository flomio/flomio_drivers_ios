//
//  AppDelegate.m
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize nfcAdapter;
@synthesize tagReadWriteViewController;
@synthesize rootTabBarController;
@synthesize window;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.nfcAdapter = [[FJNFCAdapter alloc] init];
    [self.nfcAdapter setDelegate:self];
    
    LoggingViewController *loggingViewController;
    UtilitiesViewController *utilitiesViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.tagReadWriteViewController = [[TagReadWriteViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
        loggingViewController = [[LoggingViewController alloc] initWithNibName:@"LoggingViewController_iPhone" bundle:nil];
        utilitiesViewController = [[UtilitiesViewController alloc] initWithNibName:@"UtilitiesViewController_iPhone" bundle:nil];
        
    } else {
        self.tagReadWriteViewController = [[TagReadWriteViewController alloc] initWithNibName:@"TagReadWriteViewController_iPad" bundle:nil];
        loggingViewController = [[LoggingViewController alloc] initWithNibName:@"LoggingViewController_iPad" bundle:nil];
        utilitiesViewController = [[UtilitiesViewController alloc] initWithNibName:@"UtilitiesViewController_iPad" bundle:nil];
    }
    
    NSArray *viewControllersArray = [[NSArray alloc] initWithObjects:self.tagReadWriteViewController, utilitiesViewController, loggingViewController,  nil];
    
    self.rootTabBarController = [[UITabBarController alloc] init];
    [self.rootTabBarController setViewControllers:viewControllersArray animated:YES];
    
    self.window.rootViewController = self.rootTabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark - FJNFCAdapterDelegate

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didScanTag:(FJNFCTag *)theNfcTag {
    NSLog(@"FloJack Tag Scanned: %@", [[theNfcTag uid] fj_asHexString]);
    if ([self.rootTabBarController.selectedViewController respondsToSelector:@selector(nfcAdapter: didScanTag:)]) {
        [(id)self.rootTabBarController.selectedViewController nfcAdapter:theNfcAdapter didScanTag:theNfcTag];        
    }
}

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didHaveStatus:(NSInteger)statusCode {
    NSLog(@"FloJack Status: %d", statusCode);
    if ([self.rootTabBarController.selectedViewController respondsToSelector:@selector(nfcAdapter: didHaveStatus:)]) {
        [(id)self.rootTabBarController.selectedViewController nfcAdapter:theNfcAdapter didHaveStatus:statusCode];
    }
}

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didWriteTagAndStatusWas:(NSInteger)statusCode {
    NSLog(@"FloJack Write Status: %d", statusCode);
    if ([self.rootTabBarController.selectedViewController respondsToSelector:@selector(nfcAdapter: didWriteTagAndStatusWas:)]) {
        [(id)self.rootTabBarController.selectedViewController nfcAdapter:theNfcAdapter didWriteTagAndStatusWas:statusCode];
    }
}

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didReceiveFirmwareVersion:(NSString*)theVersionNumber {
    NSLog(@"FloJack Firmware Version: %@", theVersionNumber);
    if ([self.rootTabBarController.selectedViewController respondsToSelector:@selector(nfcAdapter: didReceiveFirmwareVersion:)]) {
        [(id)self.rootTabBarController.selectedViewController nfcAdapter:theNfcAdapter didReceiveFirmwareVersion:theVersionNumber];
    }
}

- (void)nfcAdapter:(FJNFCAdapter *)theNfcAdapter didReceiveHardwareVersion:(NSString*)theVersionNumber; {
    NSLog(@"FloJack Hardware Version: %@", theVersionNumber);
    if ([self.rootTabBarController.selectedViewController respondsToSelector:@selector(nfcAdapter: didReceiveHardwareVersion:)]) {
        [(id)self.rootTabBarController.selectedViewController nfcAdapter:theNfcAdapter didReceiveHardwareVersion:theVersionNumber];
    }
}

@end
