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
 * The <code>AJDIccProtocolViewController</code> class selects the protocol for
 * the ICC.
 * @author  Godfrey Chung
 * @version 1.0, 18 Feb 2014
 */
@interface AJDIccProtocolViewController : UITableViewController

/** Protocols. */
@property (nonatomic) NSUInteger protocols;

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
 * The <code>AJDIccProtocolViewControllerDelegate</code> protocol defines the
 * response sent to a delegate of <code>AJDIccProtocolViewController</code>
 * object.
 */
@protocol AJDIccProtocolViewControllerDelegate <NSObject>
@optional

/**
 * Tells the delegate that the protocols had been selected.
 * @param iccProtocolViewController the ICC protocol view controller.
 * @param protocols                 the protocols.
 */
- (void)iccProtocolViewController:(AJDIccProtocolViewController *)iccProtocolViewController didSelectProtocols:(NSUInteger)protocols;

@end
