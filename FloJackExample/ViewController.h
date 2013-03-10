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

@property (retain, nonatomic) IBOutlet UITextView *outputTextView;
@property (retain, nonatomic) IBOutlet UITextView *loggingTextView;
@property (retain, nonatomic) IBOutlet UITextField *urlInputField;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic)  NSInteger statusPingPongCount;
@property (weak, nonatomic) IBOutlet UITextView *statusPingPongTextView;
@property (nonatomic)  NSInteger statusNACKCount;
@property (weak, nonatomic) IBOutlet UITextView *statusNackTextView;
@property (nonatomic)  NSInteger statusErrorCount;
@property (weak, nonatomic) IBOutlet UITextView *statusErrorTextView;
@property (weak, nonatomic) IBOutlet UITextView *volumeLowErrorTextView;

- (IBAction)buttonWasPressed:(id)sender;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
