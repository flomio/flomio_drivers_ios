/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "AJDIccViewController.h"
#import "AudioJack/AudioJack.h"
#import "AJDHex.h"

@interface AJDIccViewController ()

@property (weak, nonatomic) IBOutlet UILabel *atrLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerActionLabel;
@property (weak, nonatomic) IBOutlet UILabel *waitTimeoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *protocolLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeProtocolLabel;
@property (weak, nonatomic) IBOutlet UILabel *commandApduLabel;
@property (weak, nonatomic) IBOutlet UILabel *responseApduLabel;
@property (weak, nonatomic) IBOutlet UILabel *controlCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *controlCommandLabel;
@property (weak, nonatomic) IBOutlet UILabel *controlResponseLabel;

@end

@implementation AJDIccViewController {

    id <AJDIccViewControllerDelegate> _delegate;
    NSUserDefaults *_defaults;
    NSUInteger _powerAction;
    NSTimeInterval _waitTimeout;
    NSUInteger _protocols;
    NSData *_commandApdu;
    NSUInteger _controlCode;
    NSData *_controlCommand;
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

    _defaults = [NSUserDefaults standardUserDefaults];

    // Load the power action.
    NSNumber *powerAction = [_defaults objectForKey:@"IccPowerAction"];
    if (powerAction != nil) {

        _powerAction = [powerAction unsignedIntegerValue];
        if (_powerAction > ACRCardWarmReset) {
            _powerAction = ACRCardWarmReset;
        }

    } else {

        _powerAction = ACRCardWarmReset;
    }
    self.powerActionLabel.text = [self AJD_toPowerActionString:_powerAction];

    // Load the wait timeout.
    NSNumber *waitTimeout = [_defaults objectForKey:@"IccWaitTimeout"];
    if (waitTimeout != nil) {

        _waitTimeout = [waitTimeout doubleValue];
        if (_waitTimeout < 0) {
            _waitTimeout = 10;
        }

    } else {

        _waitTimeout = 10;
    }
    self.waitTimeoutLabel.text = [NSString stringWithFormat:@"%.2f sec(s)", _waitTimeout];

    // Load the protocols.
    NSNumber *protocols = [_defaults objectForKey:@"IccProtocols"];
    if (protocols != nil) {
        _protocols = [protocols unsignedIntegerValue];
    } else {
        _protocols = ACRProtocolT0 | ACRProtocolT1;
    }
    self.protocolLabel.text = [self AJD_toProtocolString:_protocols];

    // Load the command APDU.
    _commandApdu = [_defaults dataForKey:@"IccCommandApdu"];
    if (_commandApdu == nil) {

        uint8_t buffer[] = { 0x00, 0x84, 0x00, 0x00, 0x08 };
        _commandApdu = [NSData dataWithBytes:buffer length:sizeof(buffer)];
    }
    self.commandApduLabel.text = [AJDHex hexStringFromByteArray:_commandApdu];

    // Load the control code.
    NSNumber *controlCode = [_defaults objectForKey:@"IccControlCode"];
    if (controlCode != nil) {
        _controlCode = [controlCode unsignedIntegerValue];
    } else {
        _controlCode = ACRIoctlCcidEscape;
    }
    self.controlCodeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_controlCode];

    // Load the control command.
    _controlCommand = [_defaults dataForKey:@"IccControlCommand"];
    if (_controlCommand == nil) {

        uint8_t buffer[] = { 0xE0, 0x00, 0x00, 0x18, 0x00 };
        _controlCommand = [NSData dataWithBytes:buffer length:sizeof(buffer)];
    }
    self.controlCommandLabel.text = [AJDHex hexStringFromByteArray:_controlCommand];

    self.atrLabel.text = @"";
    self.activeProtocolLabel.text = @"";
    self.responseApduLabel.text = @"";
    self.controlResponseLabel.text = @"";

    self.atrLabel.numberOfLines = 0;
    self.commandApduLabel.numberOfLines = 0;
    self.responseApduLabel.numberOfLines = 0;
    self.controlCommandLabel.numberOfLines = 0;
    self.controlResponseLabel.numberOfLines = 0;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowPowerAction"]) {

        AJDIccPowerActionViewController *iccPowerActionViewController = segue.destinationViewController;
        [iccPowerActionViewController setDelegate:self];
        iccPowerActionViewController.powerAction = _powerAction;

    } else if ([segue.identifier isEqualToString:@"ShowProtocol"]) {

        AJDIccProtocolViewController *iccProtocolViewController = segue.destinationViewController;
        [iccProtocolViewController setDelegate:self];
        iccProtocolViewController.protocols = _protocols;
    }
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if ([cell.reuseIdentifier isEqualToString:@"WaitTimeout"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait Timeout" message:@"Enter the value:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 0;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeNumberPad;
        alertTextField.text = [NSString stringWithFormat:@"%.02f", _waitTimeout];

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"CommandApdu"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Command APDU" message:@"Enter the HEX string:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 1;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = [AJDHex hexStringFromByteArray:_commandApdu];

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"ControlCode"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Control Code" message:@"Enter the value:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 2;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeNumberPad;
        alertTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)_controlCode];

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"ControlCommand"]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Control Command" message:@"Enter the HEX string:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 3;

        UITextField *alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = [AJDHex hexStringFromByteArray:_controlCommand];

        [alert show];

    } else if ([cell.reuseIdentifier isEqualToString:@"Reset"]) {

        if ([_delegate respondsToSelector:@selector(iccViewControllerDidReset:)]) {
            [_delegate iccViewControllerDidReset:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"Power"]) {

        // Show the progress.
        NSArray *messages = [NSArray arrayWithObjects:@"Powering down the ICC...", @"Resetting the ICC (cold reset)...", @"Resetting the ICC (warm reset)...", nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[messages objectAtIndex:_powerAction] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];

        // Clear the ATR.
        self.atrLabel.text = @"";
        [self.tableView reloadData];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSData *atr = nil;
            NSError *error = nil;

            @try {

                // Do the power action.
                atr = [self.reader powerCardWithAction:(ACRCardPowerAction)_powerAction slotNum:0 timeout:_waitTimeout error:&error];
                if (atr == nil) {

                    // Show the error.
                    [self AJD_showError:error];

                } else {

                    // Show the ATR.
                    dispatch_async(dispatch_get_main_queue(), ^{

                        self.atrLabel.text = [AJDHex hexStringFromByteArray:atr];
                        [self.tableView reloadData];
                    });
                }
            }
            @catch (NSException *exception) {
                [self AJD_showException:exception];
            }

            // Hide the progress.
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
            });
        });

    } else if ([cell.reuseIdentifier isEqualToString:@"SetProtocol"]) {

        // Show the progress.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Setting the protocol..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];

        // Clear the active protocol.
        self.activeProtocolLabel.text = @"";
        [self.tableView reloadData];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSUInteger activeProtocol = ACRProtocolUndefined;
            NSError *error = nil;

            @try {

                // Set the protocol.
                activeProtocol = [self.reader setProtocol:_protocols slotNum:0 timeout:_waitTimeout error:&error];
                if (error != nil) {

                    // Show the error.
                    [self AJD_showError:error];

                } else {

                    // Show the active protocol.
                    dispatch_async(dispatch_get_main_queue(), ^{

                        switch (activeProtocol) {

                            case ACRProtocolT0:
                                self.activeProtocolLabel.text = @"T=0";
                                break;

                            case ACRProtocolT1:
                                self.activeProtocolLabel.text = @"T=1";
                                break;

                            default:
                                self.activeProtocolLabel.text = @"Unknown";
                                break;
                        }

                        [self.tableView reloadData];
                    });
                }
            }
            @catch (NSException *exception) {
                [self AJD_showException:exception];
            }

            // Hide the progress.
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
            });
        });

    } else if ([cell.reuseIdentifier isEqualToString:@"Transmit"]) {

        // Show the progress.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Transmitting the command APDU..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];

        // Clear the response APDU.
        self.responseApduLabel.text = @"";
        [self.tableView reloadData];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSData *responseApdu = nil;
            NSError *error = nil;

            @try {

                // Transmit the command APDU.
                responseApdu = [self.reader transmitApdu:_commandApdu slotNum:0 timeout:_waitTimeout error:&error];
                if (responseApdu == nil) {

                    // Show the error.
                    [self AJD_showError:error];

                } else {

                    // Show the response APDU.
                    dispatch_async(dispatch_get_main_queue(), ^{

                        self.responseApduLabel.text = [AJDHex hexStringFromByteArray:responseApdu];
                        [self.tableView reloadData];
                    });
                }
            }
            @catch (NSException *exception) {
                [self AJD_showException:exception];
            }

            // Hide the progress.
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
            });
        });

    } else if ([cell.reuseIdentifier isEqualToString:@"Control"]) {

        // Show the progress.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Transmitting the control command..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];

        // Clear the control response.
        self.controlResponseLabel.text = @"";
        [self.tableView reloadData];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSData *controlResponse = nil;
            NSError *error = nil;

            @try {

                // Transmit the control command.
                controlResponse = [self.reader transmitControlCommand:_controlCommand controlCode:_controlCode slotNum:0 timeout:_waitTimeout error:&error];
                if (controlResponse == nil) {

                    // Show the error.
                    [self AJD_showError:error];

                } else {

                    // Show the control response.
                    dispatch_async(dispatch_get_main_queue(), ^{

                        self.controlResponseLabel.text = [AJDHex hexStringFromByteArray:controlResponse];
                        [self.tableView reloadData];
                    });
                }
            }
            @catch (NSException *exception) {
                [self AJD_showException:exception];
            }

            // Hide the progress.
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
            });
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = tableView.rowHeight;
    UILabel *label = nil;

    switch (indexPath.section) {

        case 0:
            if (indexPath.row == 0) {
                label = self.atrLabel;
            }
            break;

        case 2:
            if (indexPath.row == 0) {
                label = self.commandApduLabel;
            } else if (indexPath.row == 1) {
                label = self.responseApduLabel;
            }
            break;

        case 3:
            if (indexPath.row == 1) {
                label = self.controlCommandLabel;
            } else if (indexPath.row == 2) {
                label = self.controlResponseLabel;
            }
            break;

        default:
            break;
    }

    if (label != nil) {

        // Adjust the cell height.
//        CGSize labelSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(tableView.frame.size.width - 40.0, MAXFLOAT) lineBreakMode:label.lineBreakMode];
        CGSize labelSize = CGSizeMake(0,94);
        height += labelSize.height;
    }

    return height;
}

#pragma mark - Icc Power Action View Controller

- (void)iccPowerActionViewController:(AJDIccPowerActionViewController *)iccPowerActionViewController didSelectPowerAction:(NSUInteger)powerAction {

    if (_powerAction != powerAction) {

        _powerAction = powerAction;
        self.powerActionLabel.text = [self AJD_toPowerActionString:_powerAction];

        // Save the power action.
        [_defaults setObject:[NSNumber numberWithUnsignedInteger:_powerAction] forKey:@"IccPowerAction"];
        [_defaults synchronize];
    }
}

#pragma mark - Icc Protocol View Controller

- (void)iccProtocolViewController:(AJDIccProtocolViewController *)iccProtocolViewController didSelectProtocols:(NSUInteger)protocols {

    if (_protocols != protocols) {

        _protocols = protocols;
        self.protocolLabel.text = [self AJD_toProtocolString:_protocols];

        // Save the protocols.
        [_defaults setObject:[NSNumber numberWithUnsignedInteger:_protocols] forKey:@"IccProtocols"];
        [_defaults synchronize];
    }
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSUInteger waitTimeout = 0;
    NSData *commandApdu = nil;
    NSUInteger controlCode = 0;
    NSData *controlCommand = nil;

    switch (alertView.tag) {

        case 0: // Wait timeout.
            waitTimeout = [[alertView textFieldAtIndex:0].text doubleValue];
            if (_waitTimeout != waitTimeout) {

                _waitTimeout = waitTimeout;

                if ((_waitTimeout == HUGE_VAL) ||
                    (_waitTimeout == -HUGE_VAL) ||
                    (_waitTimeout < 0)) {
                    _waitTimeout = 10;
                }

                self.waitTimeoutLabel.text = [NSString stringWithFormat:@"%.2f sec(s)", _waitTimeout];

                // Save the wait timeout.
                [_defaults setObject:[NSNumber numberWithDouble:_waitTimeout] forKey:@"IccWaitTimeout"];
                [_defaults synchronize];
            }
            break;

        case 1: // Command APDU.
            commandApdu = [AJDHex byteArrayFromHexString:[alertView textFieldAtIndex:0].text];
            if (![_commandApdu isEqualToData:commandApdu]) {

                _commandApdu = commandApdu;
                self.commandApduLabel.text = [AJDHex hexStringFromByteArray:_commandApdu];

                // Save the command APDU.
                [_defaults setObject:_commandApdu forKey:@"IccCommandApdu"];
                [_defaults synchronize];
            }
            break;

        case 2: // Control code.
            controlCode = [[alertView textFieldAtIndex:0].text integerValue];
            if (_controlCode != controlCode) {

                _controlCode = controlCode;
                self.controlCodeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_controlCode];

                // Save the control code.
                [_defaults setObject:[NSNumber numberWithUnsignedInteger:_controlCode] forKey:@"IccControlCode"];
                [_defaults synchronize];
            }
            break;

        case 3: // Control command.
            controlCommand = [AJDHex byteArrayFromHexString:[alertView textFieldAtIndex:0].text];
            if (![_controlCommand isEqualToData:controlCommand]) {

                _controlCommand = controlCommand;
                self.controlCommandLabel.text = [AJDHex hexStringFromByteArray:_controlCommand];

                // Save the control command.
                [_defaults setObject:_controlCommand forKey:@"IccControlCommand"];
                [_defaults synchronize];
            }
            break;

        default:
            break;
    }
}

#pragma mark - Private Methods

/**
 * Converts the power action to string.
 * @param powerAction the power action.
 * @return the power action string.
 */
- (NSString *)AJD_toPowerActionString:(NSUInteger)powerAction {

    NSString *powerActionString = @"";

    switch (powerAction) {

        case ACRCardPowerDown:
            powerActionString = @"Power Down";
            break;

        case ACRCardColdReset:
            powerActionString = @"Cold Reset";
            break;

        case ACRCardWarmReset:
            powerActionString = @"Warm Reset";
            break;

        default:
            break;
    }

    return powerActionString;
}

/**
 * Converts the protocols to string.
 * @param protocols the protocols.
 * @return the protocol string.
 */
- (NSString *)AJD_toProtocolString:(NSUInteger)protocols {

    NSString *protocolString = @"";

    if (_protocols & ACRProtocolT0) {
        protocolString = [protocolString stringByAppendingString:@"T=0"];
    }

    if (_protocols & ACRProtocolT1) {

        if ([protocolString length] > 0) {
            protocolString = [protocolString stringByAppendingString:@" or "];
        }

        protocolString = [protocolString stringByAppendingString:@"T=1"];
    }

    return protocolString;
}

/**
 * Shows the error.
 * @param error the error.
 */
- (void)AJD_showError:(NSError *)error {

    dispatch_async(dispatch_get_main_queue(), ^{

        // Show the error.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}

/**
 * Shows the exception.
 * @param exception the exception.
 */
- (void)AJD_showException:(NSException *)exception {

    dispatch_async(dispatch_get_main_queue(), ^{

        // Show the exception.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[exception reason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}

@end
