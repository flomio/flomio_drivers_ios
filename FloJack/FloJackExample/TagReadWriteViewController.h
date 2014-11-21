//
//  TagReadWriteViewController.h
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <dispatch/dispatch.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "FJNFCAdapter.h"
#import "NSData+FJStringDisplay.h"

@interface TagReadWriteViewController : UIViewController <AVAudioPlayerDelegate, FJNFCAdapterDelegate, UIScrollViewDelegate>

@property (nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITextField *pollingRateTextField;
@property (strong, nonatomic) IBOutlet UITextView *outputTextView;
@property (nonatomic)  NSInteger statusErrorCount;
@property (strong, nonatomic) IBOutlet UITextView *statusErrorTextView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic)  NSInteger statusPingPongCount;
@property (strong, nonatomic) IBOutlet UITextView *statusPingPongTextView;
@property (nonatomic)  NSInteger statusNACKCount;
@property (strong, nonatomic) IBOutlet UITextView *statusNACKTextView;
@property (strong, nonatomic) IBOutlet UITextView *statusVolumeLowErrorTextView;
@property (strong, nonatomic) IBOutlet UITextField *urlInputField;
@property (weak, nonatomic) IBOutlet UITextField *tweakThresholdTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxThresholdTextField;
@property (weak, nonatomic) IBOutlet UISwitch *switchPolling14443A;
@property (weak, nonatomic) IBOutlet UISwitch *switchPolling15693;
@property (weak, nonatomic) IBOutlet UISwitch *switchPollingFelica;
@property (weak, nonatomic) IBOutlet UISwitch *switchStandaloneMode;
@property (weak, nonatomic) IBOutlet UITextField *ledConfigTextField;

- (IBAction)buttonWasPressedForPollingRate:(id)sender;
- (IBAction)buttonWasPressedForReadTag:(id)sender;
- (IBAction)buttonWasPressedForUtilities:(id)sender;
- (IBAction)buttonWasPressedForWriteTag:(id)sender;
- (IBAction)switchWasFlippedForConfig:(id)sender;
- (IBAction)buttonWasPressedForSendConfig:(id)sender;
- (IBAction)buttonWasPressedForLEDConfig:(id)sender;

@end
