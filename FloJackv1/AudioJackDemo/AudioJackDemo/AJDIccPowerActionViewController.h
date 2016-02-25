/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <UIKit/UIKit.h>

/**
 * The <code>AJDIccPowerActionViewController</code> class selects the power
 * action for the ICC interface.
 * @author  Godfrey Chung
 * @version 1.0, 18 Feb 2014
 */
@interface AJDIccPowerActionViewController : UITableViewController

/** Power action. */
@property (nonatomic) NSUInteger powerAction;

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
 * The <code>AJDIccPowerActionViewControllerDelegate</code> protocol defines the
 * response sent to a delegate of <code>AJDIccPowerActionViewController</code>
 * object.
 */
@protocol AJDIccPowerActionViewControllerDelegate <NSObject>
@optional

/**
 * Tells the delegate that the power action had been selected.
 * @param iccPowerActionViewController the ICC power action view controller.
 * @param powerAction                  the power action.
 */
- (void)iccPowerActionViewController:(AJDIccPowerActionViewController *)iccPowerActionViewController didSelectPowerAction:(NSUInteger)powerAction;

@end
