//
//  AppDelegate.h
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FLOReaderManager.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, FLOReaderManagerDelegate>

@property (strong, nonatomic) UIWindow          *window;
@property (strong, nonatomic) FLOReaderManager      *floReaderManager;
//@property (strong, nonatomic) NSSound * scanSound;

- (void)playTagReadSound;

@end
