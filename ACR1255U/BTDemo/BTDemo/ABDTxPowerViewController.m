/*
 * Copyright (C) 2015 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "ABDTxPowerViewController.h"
#import <ACSBluetooth/ACSBluetooth.h>

@interface ABDTxPowerViewController ()

@end

@implementation ABDTxPowerViewController {

    NSArray *_txPowerStrings;
    NSUInteger _txPowerIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    _txPowerStrings = [NSArray arrayWithObjects:@"-23 dBm", @"-6 dBm", @"0 dBm", @"4 dBm", nil];

    _txPowerIndex = [_txPowerStrings indexOfObject:self.txPowerLabel.text];
    if (_txPowerIndex == NSNotFound) {
        _txPowerIndex = 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _txPowerStrings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellId = [_txPowerStrings objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    cell.textLabel.text = cellId;
    if (_txPowerIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (_txPowerIndex != indexPath.row) {

        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_txPowerIndex inSection:0];

        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        if (newCell.accessoryType == UITableViewCellAccessoryNone) {

            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            _txPowerIndex = indexPath.row;
            self.txPowerLabel.text = [_txPowerStrings objectAtIndex:_txPowerIndex];
        }

        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    if ([self.bluetoothReader isKindOfClass:[ABTAcr1255uj1Reader class]]) {

        uint8_t command[] = { 0xE0, 0x00, 0x00, 0x49, _txPowerIndex };
        [self.bluetoothReader transmitEscapeCommand:command length:sizeof(command)];
    }
}

@end
