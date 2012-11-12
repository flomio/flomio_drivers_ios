//
//  ViewController.m
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    FJNFCAdapter *_nfcAdapter;
}

@synthesize textView;

#pragma mark - UI View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _nfcAdapter = [[FJNFCAdapter alloc] init];
    [_nfcAdapter setDelegate:self];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonWasPressed:(id)sender {
    switch (((UIButton *)sender).tag){
        // LEFT COLUMN
        case 0:
            [_nfcAdapter sendMessageToHost:(UInt8 *)protocol_14443A_msg];
            break;
        case 1:
            [_nfcAdapter sendMessageToHost:(UInt8 *)protocol_14443A_off_msg];
            break;
        case 2:
            [_nfcAdapter sendMessageToHost:(UInt8 *)protocol_14443B_msg];
            break;
        case 3:
            [_nfcAdapter sendMessageToHost:(UInt8 *)protocol_14443B_off_msg];
            break;
        case 4:
            [_nfcAdapter sendMessageToHost:(UInt8 *)protocol_15693_msg];
            break;
        case 5:
            [_nfcAdapter sendMessageToHost:(UInt8 *)protocol_15693_off_msg];
            break;
        case 6:
            [_nfcAdapter sendMessageToHost:(UInt8 *)protocol_felica_msg];
            break;
        case 7:
            [_nfcAdapter sendMessageToHost:(UInt8 *)protocol_felica_off_msg];
            break;
        case 8:
            [_nfcAdapter sendMessageToHost:(UInt8 *)status_msg];
            break;
            
        // MIDDLE COLUMN
        case 9:
            [_nfcAdapter sendMessageToHost:(UInt8 *)status_sw_rev_msg];
            break;
        case 10:
            [_nfcAdapter sendMessageToHost:(UInt8 *)status_hw_rev_msg];
            break;
        case 11:
            [_nfcAdapter sendMessageToHost:(UInt8 *)dump_log_all_msg];
            break;
        case 12:
            [_nfcAdapter sendMessageToHost:(UInt8 *)keep_alive_time_infinite_msg];
            break;
        case 13:
            [_nfcAdapter sendMessageToHost:(UInt8 *)keep_alive_time_one_min_msg];
            break;
            
         // RIGHT COLUMN
        case 14:
            [_nfcAdapter sendMessageToHost:(UInt8 *)polling_enable_msg];
            break;
        case 15:
            [_nfcAdapter sendMessageToHost:(UInt8 *)polling_disable_msg];
            break;
        case 16:
            [_nfcAdapter sendMessageToHost:(UInt8 *)ack_enable_msg];
            break;
        case 17:
            [_nfcAdapter sendMessageToHost:(UInt8 *)ack_disable_msg];
            break;
        case 18:
            [_nfcAdapter sendMessageToHost:(UInt8 *)standalone_enable_msg];
            break;
        case 19:
            [_nfcAdapter sendMessageToHost:(UInt8 *)standalone_disable_msg];
            break;
        case 20:
            [_nfcAdapter sendMessageToHost:(UInt8 *)polling_frequency_1000ms_msg];
            break;
        case 21:
            [_nfcAdapter sendMessageToHost:(UInt8 *)polling_frequency_3000ms_msg];
            break;
        case 22:
            [_nfcAdapter sendMessageToHost:(UInt8 *)ti_host_command_led_on_msg];
            break;
        case 23:
            [_nfcAdapter sendMessageToHost:(UInt8 *)ti_host_command_led_off_msg];
            break;
    }
}

#pragma mark - NFC Adapter Protocol

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didScanTag:(FJNFCTag *)theNfcTag {
    
    NSLog(@"Tag uid: %@", [[theNfcTag uid] fj_asHexString]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        textView.text = [NSString stringWithFormat:@"%@ - %@",textView.text, [[theNfcTag uid] fj_asHexString]];
    });
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveFirmwareVersion:(NSString*)theVersionNumber {
    dispatch_async(dispatch_get_main_queue(), ^{
        textView.text = [NSString stringWithFormat:@"%@ - Firmware v%@", textView.text, theVersionNumber];
    });
    
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveHardwareVersion:(NSString*)theVersionNumber; {
    dispatch_async(dispatch_get_main_queue(), ^{
        textView.text = [NSString stringWithFormat:@"%@ - Hardware v%@", textView.text, theVersionNumber];
    });
}

- (BOOL)nfcAdapter:(id)sender shouldSendMessage:(NSData *)theMessage; {
    // TODO
    return false;
}




@end
