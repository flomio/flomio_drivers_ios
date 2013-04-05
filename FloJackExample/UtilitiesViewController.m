//
//  UtilitiesViewController.m
//  FloJack
//
//  Created by John Bullard on 3/25/13.
//  Copyright (c) 2013 John Bullard. All rights reserved.
//

#import "UtilitiesViewController.h"

@interface UtilitiesViewController ()

@end



@implementation UtilitiesViewController

@synthesize loggingOutputTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] init];
        self.tabBarItem.title = @"Utilities";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pollingRateTextField.text = @"750";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)buttonWasPressed:(id)sender {
    // dismiss keyboard
    [self.view endEditing:YES];
    
    AppDelegate *appDelegate = (AppDelegate *) UIApplication.sharedApplication.delegate;
    switch (((UIButton *)sender).tag) {
        case 1:
            [appDelegate.nfcAdapter getFirmwareVersion];
            break;
        case 2:
            [appDelegate.nfcAdapter initializeFloJackDevice];
            break;
        case 3:
            [appDelegate.nfcAdapter getHardwareVersion];
            break;
        case 4:
            // TODO: Add confirmation to this setting
            [appDelegate.nfcAdapter setDeviceHasVolumeCap:true];
            break;
    }
}

- (IBAction)switchWasFlipped:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *) UIApplication.sharedApplication.delegate;
    UISwitch *onOffSwitch = (UISwitch *) sender;
    switch (onOffSwitch.tag) {
        case 1:
            appDelegate.nfcAdapter.pollFor14443aTags = onOffSwitch.on;
            break;
        case 2:
            appDelegate.nfcAdapter.pollFor15693Tags = onOffSwitch.on;
            break;
        case 3:
            appDelegate.nfcAdapter.pollForFelicaTags = onOffSwitch.on;
            break;
    }
}
                
-(IBAction)updatePollRate:(id)sender {
    [self.view endEditing:YES];
    
    AppDelegate *appDelegate = (AppDelegate *) UIApplication.sharedApplication.delegate;
    int pollValue = [self.pollingRateTextField.text intValue];    
    appDelegate.nfcAdapter.pollPeriod = pollValue;
}

- (void)viewDidUnload {
    [self setLoggingOutputTextView:nil];
    [self setPollingRateTextField:nil];
    [super viewDidUnload];
}

- (void)updateLogTextViewWithString:(NSString *)updateString {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loggingOutputTextView.text = [NSString stringWithFormat:@"%@ \n%@",self.loggingOutputTextView.text, updateString];
    });
}

#pragma mark - FJNFCAdapterDelegate

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didScanTag:(FJNFCTag *)theNfcTag {
    NSMutableString *textUpdate = [NSMutableString stringWithFormat:@":::Tag Found \nUID: %@ \nType: %d \nData: %@", [[theNfcTag uid] fj_asHexString], theNfcTag.nfcForumType,
                                   [[theNfcTag data] fj_asHexString]];
    
    if (theNfcTag.ndefMessage != nil && theNfcTag.ndefMessage.ndefRecords != nil) {
        for (FJNDEFRecord *ndefRecord in theNfcTag.ndefMessage.ndefRecords) {
            [textUpdate appendString:@"\n\nNDEF Record Found"];
            [textUpdate appendString:[NSString stringWithFormat:@"\nTNF: %d",ndefRecord.tnf]];
            [textUpdate appendString:[NSString stringWithFormat:@"\nType: %@",[ndefRecord.type fj_asHexString]]];
            [textUpdate appendString:[NSString stringWithFormat:@"\nPayload: %@ (%@)",[ndefRecord.payload fj_asHexString], [ndefRecord.payload fj_asASCIIStringEncoded]]];
            
            NSURL *url = [ndefRecord getUriFromPayload];
            if (url != nil) {
                [textUpdate appendString:[NSString stringWithFormat:@"\nURI: %@", url.description]];
            }
        }
    }
    
    [self updateLogTextViewWithString:textUpdate];
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didHaveStatus:(NSInteger)statusCode {
    NSString *statusCodeString = [FJMessage formatStatusCodesToString:(flomio_nfc_adapter_status_codes_t)statusCode];
    NSMutableString *textUpdate = [NSMutableString stringWithFormat:@":::FloJack Status %@", statusCodeString];
    [self updateLogTextViewWithString:textUpdate];
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didWriteTagAndStatusWas:(NSInteger)statusCode {
    NSString *statusCodeString = [FJMessage formatTagWriteStatusToString:(flomio_tag_write_status_opcodes_t)statusCode];
    NSMutableString *textUpdate = [NSMutableString stringWithFormat:@":::FloJack Tag Write Status %@", statusCodeString];
    [self updateLogTextViewWithString:textUpdate];
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveFirmwareVersion:(NSString*)theVersionNumber {
    NSMutableString *textUpdate = [NSMutableString stringWithFormat:@":::FloJack Firmware Version %@", theVersionNumber];
    [self updateLogTextViewWithString:textUpdate];
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveHardwareVersion:(NSString*)theVersionNumber; {
    NSMutableString *textUpdate = [NSMutableString stringWithFormat:@":::FloJack Hardware Version %@", theVersionNumber];
    [self updateLogTextViewWithString:textUpdate];
}
@end
