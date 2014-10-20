//
//  MainViewController.h
//  EMVCardReader
//
//  Created by Boris  on 10/17/14.
//  Copyright (c) 2014 LLT. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AudioJack.h"
#import "LeftMenuView.h"
#import "AppDelegate.h"

@interface MainViewController : UIViewController <ACRAudioJackReaderDelegate>{
    
    LeftMenuView *leftMenu;
    CGPoint startPosition;
    
    //Application Delegate
    AppDelegate *appDelegate;
    
    NSString  *filePath;
}

@end
