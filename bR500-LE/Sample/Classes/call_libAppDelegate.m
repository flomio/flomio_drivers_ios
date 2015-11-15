//
//  call_libAppDelegate.m
//  call_lib
//
//  Created by test on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "call_libAppDelegate.h"
#include "ft301u.h"

@implementation call_libAppDelegate

@synthesize window;
@synthesize mainViewController;



#pragma mark -
#pragma mark Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if(self.mainViewController == nil){
        disopWindow *aController = [[disopWindow alloc] initWithNibName:@"disopWindow" bundle:nil];
        self.mainViewController = aController;
//        [aController release];
    }
    
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
    [window setRootViewController:mainViewController];
    [window makeKeyAndVisible];
   // [UIApplication sharedApplication].idleTimerDisabled = YES;

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
}

extern  SCARDCONTEXT gContxtHandle;
- (void)applicationDidEnterBackground:(UIApplication *)application {
  
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    //进入后台，释放上下文
//    SCardReleaseContext(gContxtHandle);
   
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */

   
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
//进入前台，创建上下文
//      SCardEstablishContext(SCARD_SCOPE_SYSTEM,NULL,NULL,&gContxtHandle);
   
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


@end
