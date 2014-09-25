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
 * The <code>AJDDukptViewController</code> class shows the DUKPT option, the
 * IKSN and the IPEK.
 * @author  Godfrey Chung
 * @version 1.0, 23 Oct 2013
 */
@interface AJDDukptViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *dukptSwitch;
@property (weak, nonatomic) IBOutlet UILabel *iksnLabel;
@property (weak, nonatomic) IBOutlet UILabel *ipekLabel;

/** IKSN. */
@property (strong, nonatomic) NSData *iksn;

/** IPEK. */
@property (strong, nonatomic) NSData *ipek;

/**
 * Gets the delegate.
 * @return the delegate.
 */
- (id)delegate;

/**
 * Sets the delegate.
 * @param newDelegate the delegate.
 */
- (void)setDelegate:(id)newDelegate;

@end

/**
 * The <code>AJDDukptViewControllerDelegate</code> protocol defines the response
 * sent to a delegate of <code>AJDDukptViewController</code> object.
 */
@protocol AJDDukptViewControllerDelegate <NSObject>
@optional

/**
 * Tells the delegate that the IKSN had been changed.
 * @param dukptViewController the DUKPT view controller.
 * @param iksn                the IKSN.
 */
- (void)dukptViewController:(AJDDukptViewController *)dukptViewController didChangeIksn:(NSData *)iksn;

/**
 * Tells the delegate that the IPEK had been changed.
 * @param dukptViewController the DUKPT view controller.
 * @param ipek                the IPEK.
 */
- (void)dukptViewController:(AJDDukptViewController *)dukptViewController didChangeIpek:(NSData *)ipek;

/**
 * Tells the delegate that the DUKPT option had been requested.
 * @param dukptViewController the DUKPT view controller.
 */
- (void)dukptViewControllerDidGetDukptOption:(AJDDukptViewController *)dukptViewController;

/**
 * Tells the delegate that the DUKPT option modification had been requested.
 * @param dukptViewController the DUKPT view controller.
 * @param enabled             set to true to enable DUKPT. Otherwise, set to
 *                            false.
 */
- (void)dukptViewController:(AJDDukptViewController *)dukptViewController didSetDukptOption:(BOOL)enabled;

/**
 * Tells the delegate that the DUKPT initialization had been requested.
 * @param dukptViewController the DUKPT view controller.
 */
- (void)dukptViewControllerDidInitializeDukpt:(AJDDukptViewController *)dukptViewController;

@end
