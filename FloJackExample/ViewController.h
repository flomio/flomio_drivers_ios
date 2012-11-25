//
//  ViewController.h
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FJNFCAdapter.h"

#import "NSData+FJStringDisplay.h"

@interface ViewController : UIViewController <AVAudioPlayerDelegate, FJNFCAdapterDelegate>

@property (retain, nonatomic) IBOutlet UITextView *textView;

- (IBAction)buttonWasPressed:(id)sender;

@end
