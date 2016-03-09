/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <UIKit/UIKit.h>

@class CBPeripheral;

/**
 * The <code>ABDReaderViewController</code> class shows the peripherals for
 * selection.
 * @author  Godfrey Chung
 * @version 1.0, 21 May 2014
 */
@interface ABDReaderViewController : UITableViewController

/** Array of peripherals. */
@property (nonatomic) NSMutableArray *peripherals;

/** Selected peripheral. */
@property (nonatomic) CBPeripheral *peripheral;

@end
