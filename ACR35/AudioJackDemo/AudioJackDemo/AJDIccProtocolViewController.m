/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "AJDIccProtocolViewController.h"
#import "AudioJack/AudioJack.h"

@interface AJDIccProtocolViewController ()

@end

@implementation AJDIccProtocolViewController {

    id <AJDIccProtocolViewControllerDelegate> _delegate;
    NSArray *_protocolStrings;
    NSUInteger _protocolValues[2];
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

    _protocolStrings = [NSArray arrayWithObjects:@"T=0", @"T=1", nil];
    _protocolValues[0] = ACRProtocolT0;
    _protocolValues[1] = ACRProtocolT1;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellId = [_protocolStrings objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    cell.textLabel.text = cellId;
    if (self.protocols & _protocolValues[indexPath.row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {

        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.protocols |= _protocolValues[indexPath.row];

        if ([_delegate respondsToSelector:@selector(iccProtocolViewController:didSelectProtocols:)]) {
            [_delegate iccProtocolViewController:self didSelectProtocols:self.protocols];
        }

    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {

        cell.accessoryType = UITableViewCellAccessoryNone;
        self.protocols &= ~_protocolValues[indexPath.row];

        if ([_delegate respondsToSelector:@selector(iccProtocolViewController:didSelectProtocols:)]) {
            [_delegate iccProtocolViewController:self didSelectProtocols:self.protocols];
        }
    }
}

@end
