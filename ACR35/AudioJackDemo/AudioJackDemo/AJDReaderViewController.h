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
 * The <code>AJDReaderViewController</code> class shows the firmware version,
 * the battery level and the sleep timeout.
 * @author  Godfrey Chung
 * @version 1.0, 21 Oct 2013
 */
@interface AJDReaderViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *firmwareVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *sleepTimeoutLabel;

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
 * The <code>AJDReaderViewControllerDelegate</code> protocol defines the
 * response sent to a delegate of <code>AJDReaderViewController</code> object.
 */
@protocol AJDReaderViewControllerDelegate <NSObject>
@optional

/**
 * Tells the delegate that the firmware version had been requested.
 * @param readerViewController the reader view controller.
 */
- (void)readerViewControllerDidGetFirmwareVersion:(AJDReaderViewController *)readerViewController;

/**
 * Tells the delegate that the status had been requested.
 * @param readerViewController the reader view controller.
 */
- (void)readerViewControllerDidGetStatus:(AJDReaderViewController *)readerViewController;

/**
 * Tells the delegate that the sleep timeout modification had been requested.
 * @param readerViewController the reader view controller.
 * @param sleepTimeout         the sleep timeout in seconds.
 */
- (void)readerViewController:(AJDReaderViewController *)readerViewController didSetSleepTimeout:(NSUInteger)sleepTimeout;

@end
