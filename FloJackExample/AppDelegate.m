//
//  AppDelegate.m
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize viewController;
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    
    self.window.rootViewController = self.viewController;
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

//- (void) redirectConsoleLogToDocumentFolder
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask, YES);
//    
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
//    
//    //clear contents of file
//    NSFileHandle *file;
//    
//    file = [NSFileHandle fileHandleForUpdatingAtPath:logPath];
//    
//    if (file == nil)
//        NSLog(@"Failed to open file");
//    
//    [file truncateFileAtOffset: 0];
//    
//    [file closeFile];
//    
//    
//    freopen([logPath fileSystemRepresentation],"a+",stderr);
//}

@end
