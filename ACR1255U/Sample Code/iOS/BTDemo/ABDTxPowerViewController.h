/*
 * Copyright (C) 2015 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <UIKit/UIKit.h>

@class ABTBluetoothReader;

/**
 * The <code>ABDTxPowerViewController</code> class shows the Tx Power for
 * selection.
 * @author  Godfrey Chung
 * @version 1.0, 29 Apr 2015
 */
@interface ABDTxPowerViewController : UITableViewController

/** Bluetooth reader. */
@property (nonatomic) ABTBluetoothReader *bluetoothReader;

/** Tx power label. */
@property (nonatomic) UILabel *txPowerLabel;

@end
