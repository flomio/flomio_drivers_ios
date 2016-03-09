/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "ABDDeviceInfoViewController.h"

@interface ABDDeviceInfoViewController ()

@end

@implementation ABDDeviceInfoViewController

- (id)initWithStyle:(UITableViewStyle)style
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

    self.manufacturerNameLabel.text = @"";
    self.firmwareRevisionLabel.text = @"";
    self.modelNumberLabel.text = @"";
    self.serialNumberLabel.text = @"";
    self.systemIdLabel.text = @"";
    self.hardwareRevisionLabel.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
