/*
 * Copyright (C) 2013 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "AJDKeysViewController.h"
#import "AJDHex.h"

@interface AJDKeysViewController ()

@end

@implementation AJDKeysViewController {
    id <AJDKeysViewControllerDelegate> _delegate;
}

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    if (self.masterKey != nil) {
        self.masterKeyLabel.text = [AJDHex hexStringFromByteArray:self.masterKey];
    }

    if (self.masterKey2 != nil) {
        self.masterKey2Label.text = [AJDHex hexStringFromByteArray:self.masterKey2];
    }

    if (self.aesKey != nil) {
        self.aesKeyLabel.text = [AJDHex hexStringFromByteArray:self.aesKey];
    }
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

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if ([cell.reuseIdentifier isEqualToString:@"MasterKey"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Master Key" message:@"Enter the HEX string (32 characters):" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 0;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = self.masterKeyLabel.text;

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"NewMasterKey"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Master Key" message:@"Enter the HEX string (32 characters):" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 1;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = self.masterKey2Label.text;

        [alert show];


    } else if ([cell.reuseIdentifier isEqualToString:@"AesKey"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AES Key" message:@"Enter the HEX string (32 characters):" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 2;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = self.aesKeyLabel.text;

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"SetMasterKey"]) {

        if ([_delegate respondsToSelector:@selector(keysViewControllerDidSetMasterKey:)]) {
            [_delegate keysViewControllerDidSetMasterKey:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"SetAesKey"]) {

        if ([_delegate respondsToSelector:@selector(keysViewControllerDidSetAesKey:)]) {
            [_delegate keysViewControllerDidSetAesKey:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"UseDefaultKey"]) {

        if ([_delegate respondsToSelector:@selector(keysViewController:didChangeMasterKey:)]) {
            [_delegate keysViewController:self didChangeMasterKey:[AJDHex byteArrayFromHexString:@"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"]];
        }

        if ([_delegate respondsToSelector:@selector(keysViewController:didChangeMasterKey2:)]) {
            [_delegate keysViewController:self didChangeMasterKey2:[AJDHex byteArrayFromHexString:@"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"]];
        }

        if ([_delegate respondsToSelector:@selector(keysViewController:didChangeAesKey:)]) {
            [_delegate keysViewController:self didChangeAesKey:[AJDHex byteArrayFromHexString:@"4E 61 74 68 61 6E 2E 4C 69 20 54 65 64 64 79 20"]];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = tableView.rowHeight;
    UILabel *label = nil;

    switch (indexPath.section) {

        case 0:
            if (indexPath.row == 0) {
                label = self.masterKey2Label;
            } else if (indexPath.row == 1) {
                label = self.masterKeyLabel;
            } else if (indexPath.row == 2) {
                label = self.aesKeyLabel;
            }
            break;

        default:
            break;
    }

    if (label != nil) {

        // Adjust the cell height.
        CGSize labelSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(tableView.frame.size.width - 40.0, MAXFLOAT) lineBreakMode:label.lineBreakMode];

        // Set the row height to 44 if it is less than zero (iOS 8.0).
        if (height < 0) {
            height = 44;
        }

        height += labelSize.height;
    }
    
    return height;
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (alertView.tag) {

        case 0: // Master key.
            if ([_delegate respondsToSelector:@selector(keysViewController:didChangeMasterKey:)]) {
                [_delegate keysViewController:self didChangeMasterKey:[AJDHex byteArrayFromHexString:[alertView textFieldAtIndex:0].text]];
            }
            break;

        case 1: // New master key.
            if ([_delegate respondsToSelector:@selector(keysViewController:didChangeMasterKey2:)]) {
                [_delegate keysViewController:self didChangeMasterKey2:[AJDHex byteArrayFromHexString:[alertView textFieldAtIndex:0].text]];
            }
            break;

        case 2: // AES key.
            if ([_delegate respondsToSelector:@selector(keysViewController:didChangeAesKey:)]) {
                [_delegate keysViewController:self didChangeAesKey:[AJDHex byteArrayFromHexString:[alertView textFieldAtIndex:0].text]];
            }
            break;

        default:
            break;
    }
}

@end
