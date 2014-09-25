//
//  com_flomio_flobleAppDelegate.h
//  FloBleExample
//
//  Created by Richard Grundy on 1/15/14.
//  Copyright (c) 2014 Flomio, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FJNFCAdapter.h"


@interface com_flomio_flobleAppDelegate : UIResponder <UIApplicationDelegate, FJNFCAdapterDelegate>

@property (strong, nonatomic) UIWindow          *window;
@property (strong, nonatomic) FJNFCAdapter      *nfcAdapter;

@end