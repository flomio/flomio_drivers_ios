/*
 * Copyright (C) 2013 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "AJDReaderViewController.h"

@interface AJDReaderViewController ()

@end

@implementation AJDReaderViewController {
    id <AJDReaderViewControllerDelegate> _delegate;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _delegate = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.firmwareVersionLabel.text = @"";
    self.batteryLevelLabel.text = @"";
    self.sleepTimeoutLabel.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)delegate {
    return _delegate;
}

- (void)setDelegate:(id)newDelegate {
    _delegate = newDelegate;
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([cell.reuseIdentifier isEqualToString:@"GetFirmwareVersion"] ) {

        if ([_delegate respondsToSelector:@selector(readerViewControllerDidGetFirmwareVersion:)]) {
            [_delegate readerViewControllerDidGetFirmwareVersion:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"GetStatus"] ) {

        if ([_delegate respondsToSelector:@selector(readerViewControllerDidGetStatus:)]) {
            [_delegate readerViewControllerDidGetStatus:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"SetSleepTimeout"] ) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sleep Timeout" message:@"Enter the value between 4 and 20:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeNumberPad;

        [alert show];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if ([_delegate respondsToSelector:@selector(readerViewController:didSetSleepTimeout:)]) {

        NSInteger sleepTimeout = [[alertView textFieldAtIndex:0].text integerValue];
        [_delegate readerViewController:self didSetSleepTimeout:sleepTimeout];
    }
}

@end
