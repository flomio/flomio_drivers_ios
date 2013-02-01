//
//  ViewController.h
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <dispatch/dispatch.h>
#import <UIKit/UIKit.h>
#import "FJNFCAdapter.h"
#import "NSData+FJStringDisplay.h"

@interface ViewController : UIViewController <AVAudioPlayerDelegate, FJNFCAdapterDelegate>

@property (retain, nonatomic) IBOutlet UITextView *outputTextView;
@property (retain, nonatomic) IBOutlet UITextView *loggingTextView;

- (IBAction)buttonWasPressed:(id)sender;

@end
