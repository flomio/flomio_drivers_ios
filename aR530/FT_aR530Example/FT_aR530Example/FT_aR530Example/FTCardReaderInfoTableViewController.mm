//
//  FTCardReaderInfoTableViewController.m
//  FT_aR530Example
//
//  Created by yuanzhen on 14/6/12.
//  Copyright (c) 2014年 FTSafe. All rights reserved.
//

#import "FTCardReaderInfoTableViewController.h"
#import "include/FT_aR530.h"


@interface FTCardReaderInfoTableViewController () <FTaR530Delegate>

@property (strong, nonatomic) NSString *libVersion;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *firmwareVersion;
@property BOOL isViewAppeared;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation FTCardReaderInfoTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _deviceID = nil;
    _firmwareVersion = nil;
    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_indicatorView];
    _indicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    _deviceID = nil;
    _firmwareVersion = nil;
    [FTaR530 FTaR530_GetDeviceID:self];
    _libVersion = [NSString stringWithFormat:@"Library version:%@", [FTaR530 FTaR530_LibVersion],nil];
    _indicatorView.hidden = NO;
    [_indicatorView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    _isViewAppeared = YES;
//    [self updateDeviceID];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [FTaR530 removeDelegate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _isViewAppeared = NO;
    _deviceID = nil;
    _firmwareVersion = nil;
    _libVersion = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateDeviceID
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].textLabel.text = _libVersion;
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].textLabel.text = _deviceID;
        [self aquireFirmwareVersion];
    });
}

- (void)aquireFirmwareVersion
{
    [FTaR530 FTaR530_GetFirmwareVersion:self];
}

- (void)updateFirmwareVersion
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].textLabel.text = _firmwareVersion;
        _indicatorView.hidden = YES;
        [_indicatorView stopAnimating];
    });
}


#pragma mark - FTaR530Delegate Methods

- (void)FTaR530GetInfoDidComplete:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)functionNum errCode:(unsigned int)errCode
{
    NSString *retString = [NSString stringWithUTF8String:(char*)retData];
    switch (functionNum) {
        case FT_FUNCTION_NUM_GET_DEVICEID:
            _deviceID = [NSString stringWithFormat:@"Device ID:%@",retString,nil];
                [self updateDeviceID];
            break;
        case FT_FUNCTION_NUM_GET_FIRMWAREVERSION:
            _firmwareVersion = [NSString stringWithFormat:@"Firmware Version:%@",retString,nil];
            [self updateFirmwareVersion];
            break;
        default:
            break;
    }


}



@end
