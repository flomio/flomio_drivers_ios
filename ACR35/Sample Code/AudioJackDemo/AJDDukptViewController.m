/*
 * Copyright (C) 2013 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "AJDDukptViewController.h"
#import "AJDHex.h"

@interface AJDDukptViewController ()

@end

@implementation AJDDukptViewController {
    id <AJDDukptViewControllerDelegate> _delegate;
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

    if (self.iksn != nil) {
        self.iksnLabel.text = [AJDHex hexStringFromByteArray:self.iksn];
    }

    if (self.ipek != nil) {
        self.ipekLabel.text = [AJDHex hexStringFromByteArray:self.ipek];
    }

    self.iksnLabel.numberOfLines = 0;
    self.ipekLabel.numberOfLines = 0;
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

    if ([cell.reuseIdentifier isEqualToString:@"IKSN"] ) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IKSN" message:@"Enter the HEX string (20 characters):" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 0;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = self.iksnLabel.text;

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"IPEK"] ) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IPEK" message:@"Enter the HEX string (32 characters):" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 1;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = self.ipekLabel.text;

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"GetDukptOption"] ) {

        if ([_delegate respondsToSelector:@selector(dukptViewControllerDidGetDukptOption:)]) {
            [_delegate dukptViewControllerDidGetDukptOption:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"SetDukptOption"] ) {

        if ([_delegate respondsToSelector:@selector(dukptViewController:didSetDukptOption:)]) {
            [_delegate dukptViewController:self didSetDukptOption:self.dukptSwitch.on];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"InitializeDukpt"] ) {

        if ([_delegate respondsToSelector:@selector(dukptViewControllerDidInitializeDukpt:)]) {
            [_delegate dukptViewControllerDidInitializeDukpt:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"UseDefaultIksnIpek"] ) {

        if ([_delegate respondsToSelector:@selector(dukptViewController:didChangeIksn:)]) {
            [_delegate dukptViewController:self didChangeIksn:[AJDHex byteArrayFromHexString:@"FF FF 98 76 54 32 10 E0 00 00"]];
        }

        if ([_delegate respondsToSelector:@selector(dukptViewController:didChangeIpek:)]) {
            [_delegate dukptViewController:self didChangeIpek:[AJDHex byteArrayFromHexString:@"6A C2 92 FA A1 31 5B 4D 85 8A B3 A3 D7 D5 93 3A"]];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = tableView.rowHeight;
    UILabel *label = nil;

    switch (indexPath.section) {

        case 0:
            if (indexPath.row == 1) {
                label = self.iksnLabel;
            } else if (indexPath.row == 2) {
                label = self.ipekLabel;
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

        case 0: // IKSN.
            if ([_delegate respondsToSelector:@selector(dukptViewController:didChangeIksn:)]) {
                [_delegate dukptViewController:self didChangeIksn:[AJDHex byteArrayFromHexString:[alertView textFieldAtIndex:0].text]];
            }
            break;

        case 1: // IPEK.
            if ([_delegate respondsToSelector:@selector(dukptViewController:didChangeIpek:)]) {
                [_delegate dukptViewController:self didChangeIpek:[AJDHex byteArrayFromHexString:[alertView textFieldAtIndex:0].text]];
            }
            break;

        default:
            break;
    }
}

@end
