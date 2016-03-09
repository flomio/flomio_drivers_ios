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
 * The <code>AJDIdViewController</code> class shows the custom ID and the device
 * ID.
 * @author  Godfrey Chung
 * @version 1.0, 23 Oct 2013
 */
@interface AJDIdViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *customIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceIdLabel;

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
 * The <code>AJDIdViewControllerDelegate</code> protocol defines the response
 * sent to a delegate of <code>AJDIdViewController</code> object.
 */
@protocol AJDIdViewControllerDelegate <NSObject>
@optional

/**
 * Tells the delegate that the custom ID had been requested.
 * @param idViewController the ID view controller.
 */
- (void)idViewControllerDidGetCustomId:(AJDIdViewController *)idViewController;

/**
 * Tells the delegate that the custom ID modification had been requested.
 * @param idViewController the ID view controller.
 */
- (void)idViewController:(AJDIdViewController *)idViewController didSetCustomId:(NSString *)customId;

/**
 * Tells the delegate that the device ID had been requested.
 * @param idViewController the ID view controller.
 */
- (void)idViewControllerDidGetDeviceId:(AJDIdViewController *)idViewController;

@end
