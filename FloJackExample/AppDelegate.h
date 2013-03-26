//
//  AppDelegate.h
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LoggingViewController.h"
#import "TagReadWriteViewController.h"
#import "UtilitiesViewController.h"
#import "FJNFCAdapter.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, FJNFCAdapterDelegate>

@property (strong, nonatomic) TagReadWriteViewController    *tagReadWriteViewController;
@property (strong, nonatomic) UIWindow                      *window;
@property (nonatomic, strong) UITabBarController            *rootTabBarController;
@property (strong, nonatomic) FJNFCAdapter                  *nfcAdapter;

@end
