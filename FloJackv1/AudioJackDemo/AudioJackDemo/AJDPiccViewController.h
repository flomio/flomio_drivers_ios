/*
 * Copyright (C) 2013 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <UIKit/UIKit.h>

/**
 * The <code>AJDPiccViewController</code> class shows the ATR, the timeout, the
 * card type, the command APDU, the response APDU and the RF configuration.
 * @author  Godfrey Chung
 * @version 1.0, 9 Dec 2013
 */
@interface AJDPiccViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *atrLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commandApduLabel;
@property (weak, nonatomic) IBOutlet UILabel *responseApduLabel;
@property (weak, nonatomic) IBOutlet UILabel *rfConfigLabel;

/**
 * ATR string.
 */
@property (strong, nonatomic) NSString *atrString;

/**
 * Timeout.
 */
@property NSUInteger timeout;

/**
 * Card type string.
 */
@property (strong, nonatomic) NSString *cardTypeString;

/**
 * Command APDU string.
 */
@property (strong, nonatomic) NSString *commandApduString;

/**
 * Response APDU string.
 */
@property (strong, nonatomic) NSString *responseApduString;

/**
 * RF configuration string.
 */
@property (strong, nonatomic) NSString *rfConfigString;

/**
 * Gets the delegate.
 */
- (id)delegate;

/**
 * Sets the delegate.
 * @param newDelegate the delegate.
 */
- (void)setDelegate:(id)newDelegate;

@end

/**
 * The <code>AJDPiccViewControllerDelegate</code> protocol defines the response
 * sent to a delegate of <code>AJDPiccViewController</code> object.
 */
@protocol AJDPiccViewControllerDelegate <NSObject>
@optional

/**
 * Tells the delegate that the timeout had been changed.
 * @param piccViewController the PICC view controller.
 * @param timeoutString      the timeout string.
 */
- (void)piccViewController:(AJDPiccViewController *)piccViewController didChangeTimeout:(NSString *)timeoutString;

/**
 * Tells the delegate that the card type had been changed.
 * @param piccViewController the PICC view controller.
 * @param cardTypeString     the card type string.
 */
- (void)piccViewController:(AJDPiccViewController *)piccViewController didChangeCardType:(NSString *)cardTypeString;

/**
 * Tells the delegate that the command APDU had been changed.
 * @param piccViewController the PICC view controller.
 * @param commandApduString  the command APDU string.
 */
- (void)piccViewController:(AJDPiccViewController *)piccViewController didChangeCommandApdu:(NSString *)commandApduString;

/**
 * Tells the delegate that the RF configuration had been changed.
 * @param piccViewController the PICC view controller.
 * @param rfConfigString     the RF configuration string.
 */
- (void)piccViewController:(AJDPiccViewController *)piccViewController didChangeRfConfig:(NSString *)rfConfigString;

/**
 * Tells the delegate that the reset had been requested.
 * @param piccViewController the PICC view controller.
 */
- (void)piccViewControllerDidReset:(AJDPiccViewController *)piccViewController;

/**
 * Tells the delegate that the power on had been requested.
 * @param piccViewController the PICC view controller.
 */
- (void)piccViewControllerDidPowerOn:(AJDPiccViewController *)piccViewController;

/**
 * Tells the delegate that the power off had been requested.
 * @param piccViewController the PICC view controller.
 */
- (void)piccViewControllerDidPowerOff:(AJDPiccViewController *)piccViewController;

/**
 * Tells the delegate that the command APDU transmission had been requested.
 * @param piccViewController the PICC view controller.
 */
- (void)piccViewControllerDidTransmit:(AJDPiccViewController *)piccViewController;

/**
 * Tells the delegate that the RF configuration modification had been requested.
 * @param piccViewController the PICC view controller.
 */
- (void)piccViewControllerDidSetRfConfig:(AJDPiccViewController *)piccViewController;

@end
