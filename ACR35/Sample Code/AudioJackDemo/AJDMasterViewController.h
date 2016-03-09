/*
 * Copyright (C) 2013 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <UIKit/UIKit.h>
#import <AudioJack/AudioJack.h>
#import "AJDReaderViewController.h"
#import "AJDIdViewController.h"
#import "AJDKeysViewController.h"
#import "AJDDukptViewController.h"
#import "AJDTrackDataViewController.h"
#import "AJDIccViewController.h"
#import "AJDPiccViewController.h"

/**
 * The <code>AJDMasterViewController</code> class demonstrates the functionality
 * of ACS audio jack reader.
 * @author  Godfrey Chung
 * @version 1.0, 23 Jan 2013
 */
@interface AJDMasterViewController : UITableViewController <ACRAudioJackReaderDelegate, AJDReaderViewControllerDelegate, AJDIdViewControllerDelegate, AJDKeysViewControllerDelegate, AJDDukptViewControllerDelegate, AJDTrackDataViewControllerDelegate, AJDIccViewControllerDelegate, AJDPiccViewControllerDelegate>

@end
