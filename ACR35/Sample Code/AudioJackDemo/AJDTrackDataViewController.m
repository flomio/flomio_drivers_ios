/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "AJDTrackDataViewController.h"

@interface AJDTrackDataViewController ()

@end

@implementation AJDTrackDataViewController {
    id <AJDTrackDataViewControllerDelegate> _delegate;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)delegate {
    return _delegate;
}

- (void)setDelegate:(id)newDelegate {
    _delegate = newDelegate;
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if ([cell.reuseIdentifier isEqualToString:@"Reset"] ) {

        if ([_delegate respondsToSelector:@selector(trackDataViewControllerDidReset:)]) {
            [_delegate trackDataViewControllerDidReset:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"GetTrackDataOption"] ) {

        if ([_delegate respondsToSelector:@selector(trackDataViewControllerDidGetTrackDataOption:)]) {
            [_delegate trackDataViewControllerDidGetTrackDataOption:self];
        }

    } else if ([cell.reuseIdentifier isEqualToString:@"SetTrackDataOption"] ) {

        if ([_delegate respondsToSelector:@selector(trackDataViewController:didSetTrackDataOption:)]) {

            ACRTrackDataOption option = 0;

            if (self.encryptedTrack1Switch.on) {
                option |= ACRTrackDataOptionEncryptedTrack1;
            }

            if (self.encryptedTrack2Switch.on) {
                option |= ACRTrackDataOptionEncryptedTrack2;
            }

            if (self.maskedTrack1Switch.on) {
                option |= ACRTrackDataOptionMaskedTrack1;
            }

            if (self.maskedTrack2Switch.on) {
                option |= ACRTrackDataOptionMaskedTrack2;
            }

            [_delegate trackDataViewController:self didSetTrackDataOption:option];
        }
    }
}

@end
