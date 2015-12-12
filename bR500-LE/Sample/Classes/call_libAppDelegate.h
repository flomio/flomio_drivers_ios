//
//  call_libAppDelegate.h
//  call_lib
//
//  Created by test on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "disopWindow.h"


UIAlertView *progressAlert;
@interface call_libAppDelegate : UIView <UIApplicationDelegate> {
    UIWindow *window;
    disopWindow *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet disopWindow *mainViewController;

@end

