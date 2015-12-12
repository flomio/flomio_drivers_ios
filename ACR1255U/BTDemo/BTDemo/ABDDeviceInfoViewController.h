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
 * The <code>ABDDeviceInfoViewController</code> class shows the device
 * information.
 * @author  Godfrey Chung
 * @version 1.0, 21 May 2014
 */
@interface ABDDeviceInfoViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *manufacturerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareRevisionLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *systemIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *hardwareRevisionLabel;

@end
