//
//  TagReadWriteViewController.m
//  FloJackExample
//
//  Created by John Bullard on 11/12/12.
//  Copyright (c) 2012 John Bullard. All rights reserved.
//

#import "TagReadWriteViewController.h"
#import "AppDelegate.h"

@implementation TagReadWriteViewController {
    AVAudioPlayer       *_audioPlayer;
}

@synthesize outputTextView          = _outputTextView;
@synthesize urlInputField           = _urlInputField;
@synthesize scrollView              = _scrollView;
@synthesize statusPingPongCount     = _statusPingPongCount;
@synthesize statusPingPongTextView  = _statusPingPongTextView;
@synthesize statusNACKCount         = _statusNACKCount;
@synthesize statusNackTextView      = _statusNackTextView;
@synthesize statusErrorCount        = _statusErrorCount;
@synthesize statusErrorTextView     = _statusErrorTextView;
@synthesize volumeLowErrorTextView  = _volumeLowErrorTextView;

#pragma mark - UI View Controller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] init];
        self.tabBarItem.title = @"Tags";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _statusPingPongCount = 0;
    _statusNACKCount = 0;
    _statusErrorCount = 0;
    
    _scrollView.contentSize = CGSizeMake(320, 1000);
}

- (void)viewDidUnload
{
    [self setVolumeLowErrorTextView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonWasPressed:(id)sender {
    // dismiss keyboard
    [self.view endEditing:YES];
    AppDelegate *appDelegate = (AppDelegate *) UIApplication.sharedApplication.delegate;
    
    switch (((UIButton *)sender).tag) {           
        // Read Tags
        case 24:
            [appDelegate.nfcAdapter setModeReadTagUID];
            break;
        case 25:
            [appDelegate.nfcAdapter setModeReadTagData];
            break;
        case 26:
            [appDelegate.nfcAdapter operationModeWriteDataTestPrevious];
            break;
            
        // Write Tags
        case 27: {
            FJNDEFMessage *testMessage = [FJNDEFMessage createURIWithSting:@"http://www.flomio.com"];
            NSLog(@"%@", [testMessage.asByteBuffer fj_asHexString]);
            [appDelegate.nfcAdapter setModeWriteTagWithNdefMessage:testMessage];
            break;
        }
        case 28: {
            FJNDEFMessage *testMessage = [FJNDEFMessage createURIWithSting:@"http://www.ttag.be/m/04FAC9193E2580"];
            NSLog(@"%@", [testMessage.asByteBuffer fj_asHexString]);
            [appDelegate.nfcAdapter setModeWriteTagWithNdefMessage:testMessage];
            break;
        }
        case 29: {
            FJNDEFMessage *testMessage = [FJNDEFMessage createURIWithSting:_urlInputField.text];
            NSLog(@"%@", [testMessage.asByteBuffer fj_asHexString]);
            [appDelegate.nfcAdapter setModeWriteTagWithNdefMessage:testMessage];
            break;
        }
    }
}

// This forces audio through speaker even when the accessory is plugged in.
-(void)playSound:(NSString *)soundFileName
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource : soundFileName ofType :@"mp3"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        UInt32 allowMixing = true;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        NSURL *url = [NSURL fileURLWithPath:path];
        
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops = 0;
        [_audioPlayer prepareToPlay];
        _audioPlayer.delegate = self;
        
        if (_audioPlayer != nil)
        {
            [_audioPlayer play];
        }
        
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
    else
    {
        NSLog(@"error, file not found: %@", path);
    }
}

- (void)updateLogTextViewWithString:(NSString *)updateString {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.outputTextView.text = [NSString stringWithFormat:@"%@ \n%@",self.outputTextView.text, updateString];
    });
}

#pragma mark - AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    UInt32 allowMixing = true;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

#pragma mark - FJNFCAdapterDelegate

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didScanTag:(FJNFCTag *)theNfcTag {
    
    // Display the alert to the user
    NSMutableString *textUpdate = [NSMutableString stringWithFormat:@"--Tag Found-- \nUID: %@ \nType: %d \nData: %@", [[theNfcTag uid] fj_asHexString], theNfcTag.nfcForumType,
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
            
            NSLog(@"TNF: %d Type: %@ Payload: %@", ndefRecord.tnf, [ndefRecord.type fj_asHexString], [ndefRecord.payload fj_asASCIIStringEncoded]);
        }
        
    }    
    [self updateLogTextViewWithString:textUpdate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO this sends config message repeatedly which puts flojack in a bad state
       // [self playSound:@"scan_sound"];
        
        
        // Create a new alert object and set initial values.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tag Found" 
                                                        message:[NSString stringWithFormat:@"We found the following tag: %@",[[theNfcTag uid] fj_asHexString]]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];        
        [alert show];
    });
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didHaveStatus:(NSInteger)statusCode {
    NSString *statusCodeString = [FJMessage formatStatusCodesToString:(flomio_nfc_adapter_status_codes_t)statusCode];
    NSString *textUpdate = [NSString stringWithFormat:@":::FloJack Status %@", statusCodeString];
    [self updateLogTextViewWithString:textUpdate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (statusCode) {
            case FLOMIO_STATUS_PING_RECIEVED:
                _statusPingPongCount++;
                _statusPingPongTextView.text = [NSString stringWithFormat:@"PING-PONG : %d",_statusPingPongCount];
                break;
            case FLOMIO_STATUS_NACK_ERROR:
                _statusNACKCount++;
                _statusNackTextView.text = [NSString stringWithFormat:@"NACK : %d",_statusNACKCount];
                break;
            case FLOMIO_STATUS_VOLUME_LOW_ERROR:
                _volumeLowErrorTextView.text = [NSString stringWithFormat:@"**ERROR** Volume low"];
                break;
            case FLOMIO_STATUS_VOLUME_OK:
                _volumeLowErrorTextView.text = [NSString stringWithFormat:@"Volume OK"];
            case FLOMIO_STATUS_MESSAGE_CORRUPT_ERROR:
                // fall through
            case FLOMIO_STATUS_GENERIC_ERROR:
                _statusErrorCount++;
                _statusErrorTextView.text = [NSString stringWithFormat:@"ERRORS : %d", _statusErrorCount];
                break;
            default:
                break;
        }
    });
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didWriteTagAndStatusWas:(NSInteger)statusCode {
    NSString *statusCodeString = [FJMessage formatTagWriteStatusToString:(flomio_tag_write_status_opcodes_t)statusCode];
    NSString *textUpdate = [NSString stringWithFormat:@":::FloJack Tag Write Status %@", statusCodeString];
    [self updateLogTextViewWithString:textUpdate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tag Write Status"
                                                        message:[NSString stringWithFormat:@"Status: %@", statusCodeString]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveFirmwareVersion:(NSString*)theVersionNumber {
    return;
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveHardwareVersion:(NSString*)theVersionNumber; {
    return;
}

- (void)dealloc
{
}

@end
