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

@interface ViewController : UIViewController <AVAudioPlayerDelegate, FJNFCAdapterDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *outputTextView;
@property (strong, nonatomic) IBOutlet UITextView *loggingTextView;
@property (strong, nonatomic) IBOutlet UITextField *urlInputField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic)  NSInteger statusPingPongCount;
@property (strong, nonatomic) IBOutlet UITextView *statusPingPongTextView;
@property (nonatomic)  NSInteger statusNACKCount;
@property (strong, nonatomic) IBOutlet UITextView *statusNackTextView;
@property (nonatomic)  NSInteger statusErrorCount;
@property (strong, nonatomic) IBOutlet UITextView *statusErrorTextView;
@property (strong, nonatomic) IBOutlet UITextView *volumeLowErrorTextView;

- (IBAction)buttonWasPressed:(id)sender;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
