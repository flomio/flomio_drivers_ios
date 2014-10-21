/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <UIKit/UIKit.h>
#import "AudioJack/AudioJack.h"

/**
 * The <code>AJDTrackDataViewController</code> class shows the track data
 * option.
 * @author  Godfrey Chung
 * @version 1.0, 2 Apr 2014
 */
@interface AJDTrackDataViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *encryptedTrack1Switch;
@property (weak, nonatomic) IBOutlet UISwitch *encryptedTrack2Switch;
@property (weak, nonatomic) IBOutlet UISwitch *maskedTrack1Switch;
@property (weak, nonatomic) IBOutlet UISwitch *maskedTrack2Switch;

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
 * The <code>AJDTrackDataViewControllerDelegate</code> protocol defines the
 * response sent to a delegate of <code>AJDTrackDataViewController</code>
 * object.
 */
@protocol AJDTrackDataViewControllerDelegate <NSObject>
@optional

/**
 * Tells the delegate that the reset had been requested.
 * @param trackDataViewController the track data view controller.
 */
- (void)trackDataViewControllerDidReset:(AJDTrackDataViewController *)trackDataViewController;

/**
 * Tells the delegate that the track data option had been requested.
 * @param trackDataViewController the track data view controller.
 */
- (void)trackDataViewControllerDidGetTrackDataOption:(AJDTrackDataViewController *)trackDataViewController;

/**
 * Tells the delegate that the track data option modification had been
 * requested.
 * @param trackDataViewController the track data view controller.
 * @param option                  the track data option.
 */
- (void)trackDataViewController:(AJDTrackDataViewController *)trackDataViewController didSetTrackDataOption:(ACRTrackDataOption)option;

@end
