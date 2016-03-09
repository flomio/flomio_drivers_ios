/*
 * Copyright (C) 2013 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "AJDIdViewController.h"

@interface AJDIdViewController ()

@end

@implementation AJDIdViewController {
    id <AJDIdViewControllerDelegate> _delegate;
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

    self.customIdLabel.text = @"";
    self.deviceIdLabel.text = @"";
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

    if ([cell.reuseIdentifier isEqualToString:@"GetCustomId"] ) {

        if ([_delegate respondsToSelector:@selector(idViewControllerDidGetCustomId:)]) {
            [_delegate idViewControllerDidGetCustomId:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"SetCustomId"] ) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom ID" message:@"Enter the text (maximum 10 characters):" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"GetDeviceId"] ) {

        if ([_delegate respondsToSelector:@selector(idViewControllerDidGetDeviceId:)]) {
            [_delegate idViewControllerDidGetDeviceId:self];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([_delegate respondsToSelector:@selector(idViewController:didSetCustomId:)]) {
        [_delegate idViewController:self didSetCustomId:[alertView textFieldAtIndex:0].text];
    }
}

@end
