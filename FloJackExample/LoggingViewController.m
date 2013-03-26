//
//  LoggingViewController.m
//  FloJack
//
//  Created by John Bullard on 3/25/13.
//  Copyright (c) 2013 John Bullard. All rights reserved.
//

#import "LoggingViewController.h"

@interface LoggingViewController ()

@end

@implementation LoggingViewController

@synthesize loggingTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] init];
        self.tabBarItem.title = @"Logs";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateLogTextViewWithString:(NSString *)updateString {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loggingTextView.text = [NSString stringWithFormat:@"%@ \n%@",self.loggingTextView.text, updateString];
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
    NSMutableString *textUpdate = [NSMutableString stringWithFormat:@":::FloJack Status %d", statusCode];
    [self updateLogTextViewWithString:textUpdate];
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didWriteTagAndStatusWas:(NSInteger)statusCode {
    NSMutableString *textUpdate = [NSMutableString stringWithFormat:@":::FloJack Tag Write Status %d", statusCode];
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
