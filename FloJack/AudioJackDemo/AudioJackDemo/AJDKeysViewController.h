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
 * The <code>AJDKeysViewController</code> class shows the master key and the AES
 * key.
 * @author  Godfrey Chung
 * @version 1.0, 23 Oct 2013
 */
@interface AJDKeysViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *masterKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *masterKey2Label;
@property (weak, nonatomic) IBOutlet UILabel *aesKeyLabel;

/** Master key. */
@property (nonatomic) NSData *masterKey;

/** New master key. */
@property (nonatomic) NSData *masterKey2;

/** AES key. */
@property (nonatomic) NSData *aesKey;

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
 * The <code>AJDKeysViewControllerDelegate</code> protocol defines the response
 * sent to a delegate of <code>AJDKeysViewController</code> object.
 */
@protocol AJDKeysViewControllerDelegate <NSObject>
@optional

/**
 * Tells the delegate that the master key had been changed.
 * @param keysViewController the keys view controller.
 * @param masterKey          the master key.
 */
- (void)keysViewController:(AJDKeysViewController *)keysViewController didChangeMasterKey:(NSData *)masterKey;

/**
 * Tells the delegate that the new master key had been changed.
 * @param keysViewController the keys view controller.
 * @param masterKey2         the new master key.
 */
- (void)keysViewController:(AJDKeysViewController *)keysViewController didChangeMasterKey2:(NSData *)masterKey2;

/**
 * Tells the delegate that the AES key had been changed.
 * @param keysViewController the keys view controller.
 * @param aesKey             the AES key.
 */
- (void)keysViewController:(AJDKeysViewController *)keysViewController didChangeAesKey:(NSData *)aesKey;

/**
 * Tells the delegate that the master key modification had been requested.
 * @param keysViewController the keys view controller.
 */
- (void)keysViewControllerDidSetMasterKey:(AJDKeysViewController *)keysViewController;

/**
 * Tells the delegate that the AES key modification had been requested.
 * @param keysViewController the keys view controller.
 */
- (void)keysViewControllerDidSetAesKey:(AJDKeysViewController *)keysViewController;

@end
