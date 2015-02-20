/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <UIKit/UIKit.h>
#import "AJDIccPowerActionViewController.h"
#import "AJDIccProtocolViewController.h"

@class ACRAudioJackReader;

/**
 * The <code>AJDIccViewController</code> class tests the functionality of audio
 * jack readers with ICC interface.
 * @author  Godfrey Chung
 * @version 1.0, 18 Feb 2014
 */
@interface AJDIccViewController : UITableViewController <UIAlertViewDelegate, AJDIccPowerActionViewControllerDelegate, AJDIccProtocolViewControllerDelegate>

/** Reader. */
@property (nonatomic) ACRAudioJackReader *reader;

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
 * The <code>AJDIccViewControllerDelegate</code> protocol defines the response
 * sent to a delegate of <code>AJDIccViewController</code> object.
 */
@protocol AJDIccViewControllerDelegate <NSObject>
@optional

/**
 * Tells the delegate that the reset had been requested.
 * @param iccViewController the ICC view controller.
 */
- (void)iccViewControllerDidReset:(AJDIccViewController *)iccViewController;

@end
