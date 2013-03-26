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
            //[appDelegate.nfcAdapter setDeviceHasVolumeCap:true];
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

@end
