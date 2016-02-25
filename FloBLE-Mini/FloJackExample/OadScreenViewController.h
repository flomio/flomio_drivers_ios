//
//  OadScreenViewController.h
//  FloJack
//
//  Created by Chuck Carter on 3/14/15.
//  Copyright (c) 2015 John Bullard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OadFile.h"
#import "AppDelegate.h"


@protocol OadWindowControllerDelegate
@required
- (void)updateButtonPress;
@optional
//- (void)handleReceivedByte:(UInt8)byte withParity:(BOOL)parityGood atTimestamp:(double)timestamp;
//- (void)updateLog:(NSString*)logText;
//- (void) didReadHardwareRevisionString:(NSString *) string;
@end


@interface OadScreenViewController : UIViewController
{
    IBOutlet UILabel *CurrentImageType;
    IBOutlet UILabel *FirmwareVersion;
    IBOutlet UITextField *FileName;
    IBOutlet UILabel *UploadImageTypeText;
    IBOutlet UIButton *UpdateButtonIBOutlet;
    IBOutlet UIProgressView *UpdateProgressBar;
    IBOutlet UILabel *BytesStatus;
    IBOutlet UILabel *BytesPerSecStatus;
}
@property (nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) UITextField *CurrentImageTypeText;
@property (strong, nonatomic) UITextField *FirmwareVersion;
@property (strong, nonatomic) UITextField *FileName;
@property (strong, nonatomic) UIProgressView *UpdateProgressBar;
@property (strong, nonatomic) UITextField *BytesStatus;
@property (strong, nonatomic) UITextField *BytesPerSecStatus;
@property (strong, nonatomic) UITextField *UploadImageTypeText;
@property id<OadWindowControllerDelegate> delegate;

- (IBAction)UpdateButton:(id)sender;
- (IBAction)FileNameEditAction:(id)sender;
- (IBAction)UploadFileSet:(id)sender;

//- (id)initWithDelegate:(id<OadWindowControllerDelegate>)flashWindowDelegate;
//- (id)initWithDelegate:(id<OadWindowControllerDelegate>)flashWindowDelegate andOadFile:(OadFile*)theOadFile;
- (void)updateCurrentImageType:(imageType)type;
- (void)updateUploadImageType:(imageType)type;
- (void)updateFirmwareVersion:(NSString*)version;
- (void)updateFileName:(NSString*)name;
- (void)updateBytesStatus:(NSInteger)nBytes;
- (void)updateBytes:(NSInteger)nBytes perSec:(CGFloat)nSecs;
- (void)updateOadImageHeader:(oad_img_hdr_t*) oadImageHeader;
- (void)setOadFile:(OadFile *)theOadFile;
- (void)updateUpdateButton;
- (void)updateAllFields;
- (void)cancelUpdate;
- (void)endOfUpdate;
- (void) flashWindowUpdateTimerTick:(NSTimer *)time;
//- (void)windowWillClose:(NSNotification *)notification;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;


@end
