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
    AVAudioPlayer       *_audioPlayer;
    FJNFCAdapter        *_nfcAdapter;
    dispatch_queue_t    _backgroundQueue;
    
}

@synthesize outputTextView = _outputTextView;
@synthesize loggingTextView = _loggingTextView;
@synthesize urlInputField = _urlInputField;
@synthesize scrollView = _scrollView;
@synthesize statusPingPongCount     = _statusPingPongCount;
@synthesize statusPingPongTextView  = _statusPingPongTextView;
@synthesize statusNACKCount         = _statusNACKCount;
@synthesize statusNackTextView      = _statusNackTextView ;
@synthesize statusErrorCount        = _statusErrorCount;
@synthesize statusErrorTextView     = _statusErrorTextView;
@synthesize volumeLowErrorTextView  = _volumeLowErrorTextView;


#pragma mark - UI View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _nfcAdapter = [[FJNFCAdapter alloc] init];
    [_nfcAdapter setDelegate:self];
    
    _statusPingPongCount = 0;
    _statusNACKCount = 0;
    _statusErrorCount = 0;
    
    _scrollView.contentSize = CGSizeMake(320, 1000);

    
    // Poll logging file for changes (TODO: move this to event based model)
    _backgroundQueue = dispatch_queue_create("com.flomio.flojack", NULL);
    dispatch_async(_backgroundQueue, ^(void) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
        NSString *logContent = nil;
        
        while(true) {
            [NSThread sleepForTimeInterval:1.000];
            
            if (logContent.length > (100 * 20)) {
                // clear log after ~20 entries (~5 commands)
                NSFileHandle *file;
                file = [NSFileHandle fileHandleForUpdatingAtPath:logPath];
                if (file == nil)
                    NSLog(@"Failed to open file");
                
                [file truncateFileAtOffset: 0];
                [file closeFile];                
            }
            
             logContent = [NSString stringWithContentsOfFile:logPath
                                                             encoding:NSUTF8StringEncoding
                                                                error:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                _loggingTextView.text = [NSString stringWithFormat:@"%@", logContent];
            });
        }
        
    });
}

- (void)viewDidUnload
{
    //[self outputTextView:nil];
    //[self loggingTextView:nil];
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
    
    switch (((UIButton *)sender).tag) {
        // LEFT COLUMN
        case 0:  {
            [_nfcAdapter sendMessageToHost:(UInt8 *)protocol_14443A_msg];
        }
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
            
        // OPERATION MODE
        case 24:
            [_nfcAdapter sendMessageToHost:(UInt8 *)op_mode_uid_only];
            break;
        case 25:
            [_nfcAdapter sendMessageToHost:(UInt8 *)op_mode_read_memory_only];
            break;
        case 26:
            [_nfcAdapter operationModeWriteDataTestPrevious];
            break;
        case 27: {
            FJNDEFMessage *testMessage = [FJNDEFMessage createURIWithSting:@"http://www.flomio.com"];
            NSLog(@"%@", [testMessage.asByteBuffer fj_asHexString]);
            [_nfcAdapter writeTagWithNdefMessage:testMessage];
            break;
        }
        case 28: {
            FJNDEFMessage *testMessage = [FJNDEFMessage createURIWithSting:@"http://www.ttag.be/m/04FAC9193E2580"];
            NSLog(@"%@", [testMessage.asByteBuffer fj_asHexString]);
            [_nfcAdapter writeTagWithNdefMessage:testMessage];
            break;
        }
        case 29: {
            FJNDEFMessage *testMessage = [FJNDEFMessage createURIWithSting:_urlInputField.text];
            NSLog(@"%@", [testMessage.asByteBuffer fj_asHexString]);
            [_nfcAdapter writeTagWithNdefMessage:testMessage];
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

- (void)volumeChanged:(NSNotification *)notification
{
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    NSLog(@"volume: %g", volume);
}

#pragma mark - AVAudioPlayer Delegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    UInt32 allowMixing = true;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

#pragma mark - FJNFCAdapter Delegate

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didScanTag:(FJNFCTag *)theNfcTag {
    
    NSLog(@"Tag uid: %@", [[theNfcTag uid] fj_asHexString]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO this sends config message repeatedly which puts flojack in a bad state
       // [self playSound:@"scan_sound"];
        
        
        // Create a new alert object and set initial values.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tag Found" 
                                                        message:[NSString stringWithFormat:@"We found the following tag: %@",[[theNfcTag uid] fj_asHexString]]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        // Display the alert to the user
        
        NSMutableString *textUpdate = [NSMutableString stringWithFormat:@"--Tag Found-- \nUID: %@ \nData: %@", [[theNfcTag uid] fj_asHexString],
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
        
        _outputTextView.text = [NSString stringWithFormat:@"%@ \n%@",_outputTextView.text, textUpdate];
        
        [alert show];
    });
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didHaveStatus:(NSInteger)statusCode {
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
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tag Write Status"
                                                        message:[NSString stringWithFormat:@"Status: %d", statusCode]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveFirmwareVersion:(NSString*)theVersionNumber {
    dispatch_async(dispatch_get_main_queue(), ^{
        _outputTextView.text = [NSString stringWithFormat:@"%@ - Firmware v%@", _outputTextView.text, theVersionNumber];
    });
    
}

- (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveHardwareVersion:(NSString*)theVersionNumber; {
    dispatch_async(dispatch_get_main_queue(), ^{
        _outputTextView.text = [NSString stringWithFormat:@"%@ - Hardware v%@", _outputTextView.text, theVersionNumber];
    });
}

- (BOOL)nfcAdapter:(id)sender shouldSendMessage:(NSData *)theMessage; {
    // TODO
    return false;
}

- (void)dealloc
{
    dispatch_release(_backgroundQueue);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
