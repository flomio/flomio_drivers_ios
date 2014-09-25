/*
 * Copyright (C) 2013 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "AJDPiccViewController.h"

@interface AJDPiccViewController ()

@end

@implementation AJDPiccViewController {
    id <AJDPiccViewControllerDelegate> _delegate;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _delegate = nil;
        _atrString = @"";
        _timeout = 0;
        _cardTypeString = @"";
        _commandApduString = @"";
        _responseApduString = @"";
        _rfConfigString = @"";
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

    if (self.atrString != nil) {
        self.atrLabel.text = self.atrString;
    }

    self.timeoutLabel.text = [NSString stringWithFormat:@"%lu secs", (unsigned long)self.timeout];

    if (self.cardTypeString != nil) {
        self.cardTypeLabel.text = self.cardTypeString;
    }

    if (self.commandApduString != nil) {
        self.commandApduLabel.text = self.commandApduString;
    }

    if (self.responseApduString != nil) {
        self.responseApduLabel.text = self.responseApduString;
    }

    if (self.rfConfigString != nil) {
        self.rfConfigLabel.text = self.rfConfigString;
    }

    self.atrLabel.numberOfLines = 0;
    self.commandApduLabel.numberOfLines = 0;
    self.responseApduLabel.numberOfLines = 0;
    self.rfConfigLabel.numberOfLines = 0;
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

    if ([cell.reuseIdentifier isEqualToString:@"Timeout"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Timeout" message:@"Enter the value:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 0;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeNumberPad;
        alertTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.timeout];

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"CardType"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Type" message:@"Enter the HEX string:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 1;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = self.cardTypeString;

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"CommandApdu"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Command APDU" message:@"Enter the HEX string:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 2;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = self.commandApduString;

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"RfConfig"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RF Configuration" message:@"Enter the HEX string:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 3;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = self.rfConfigString;

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"Reset"]) {

        if ([_delegate respondsToSelector:@selector(piccViewControllerDidReset:)]) {
            [_delegate piccViewControllerDidReset:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"PowerOn"]) {

        if ([_delegate respondsToSelector:@selector(piccViewControllerDidPowerOn:)]) {
            [_delegate piccViewControllerDidPowerOn:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"PowerOff"]) {

        if ([_delegate respondsToSelector:@selector(piccViewControllerDidPowerOff:)]) {
            [_delegate piccViewControllerDidPowerOff:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"Transmit"]) {

        if ([_delegate respondsToSelector:@selector(piccViewControllerDidTransmit:)]) {
            [_delegate piccViewControllerDidTransmit:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"SetRfConfig"]) {

        if ([_delegate respondsToSelector:@selector(piccViewControllerDidSetRfConfig:)]) {
            [_delegate piccViewControllerDidSetRfConfig:self];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = tableView.rowHeight;

    // Adjust the cell height.
    if (indexPath.section == 0) {

        UILabel *labels[] = {

            self.atrLabel,
            self.timeoutLabel,
            self.cardTypeLabel,
            self.commandApduLabel,
            self.responseApduLabel,
            self.rfConfigLabel
        };

        CGSize labelSize;

        switch (indexPath.row) {

            case 0: // ATR.
            case 3: // Command APDU.
            case 4: // Response APDU.
            case 5: // RF configuration.
                labelSize = [labels[indexPath.row].text sizeWithFont:labels[indexPath.row].font constrainedToSize:CGSizeMake(tableView.frame.size.width - 40.0, MAXFLOAT) lineBreakMode:labels[indexPath.row].lineBreakMode];
                height += labelSize.height;
                break;

            default:
                break;
        }
    }
    
    return height;
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (alertView.tag) {

        case 0: // Timeout.
            if ([_delegate respondsToSelector:@selector(piccViewController:didChangeTimeout:)]) {
                [_delegate piccViewController:self didChangeTimeout:[alertView textFieldAtIndex:0].text];
            }
            break;

        case 1: // Card type.
            if ([_delegate respondsToSelector:@selector(piccViewController:didChangeCardType:)]) {
                [_delegate piccViewController:self didChangeCardType:[alertView textFieldAtIndex:0].text];
            }
            break;

        case 2: // Command APDU.
            if ([_delegate respondsToSelector:@selector(piccViewController:didChangeCommandApdu:)]) {
                [_delegate piccViewController:self didChangeCommandApdu:[alertView textFieldAtIndex:0].text];
            }
            break;

        case 3: // RF configuration.
            if ([_delegate respondsToSelector:@selector(piccViewController:didChangeRfConfig:)]) {
                [_delegate piccViewController:self didChangeRfConfig:[alertView textFieldAtIndex:0].text];
            }
            break;

        default:
            break;
    }
}

@end
