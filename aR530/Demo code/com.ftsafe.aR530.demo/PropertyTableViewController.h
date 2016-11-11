//
//  PropertyTableViewController.h
//  com.ftsafe.aR530.demo
//
//  Created by 李亚林 on 14/12/25.
//  Copyright (c) 2014年 李亚林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTaR530.h"
#import "NFCGeneralCardViewController.h"

#define SID_DEVICE_NOTFOUND @"View_NotFoundDevice"
#define SID_VIEW_GENERALCARD @"View_GeneralCard"
#define SID_VIEW_MIFARECARD @"View_MifareCard"
#define SID_VIEW_MIFARECARDVALUEBLOCK @"View_MifareCardValueBlock"

@interface PropertyTableViewController : UITableViewController <FTaR530Delegate>{
    FTaR530 *_ar530;
}

@property (weak, nonatomic) IBOutlet UISwitch *switchA;
@property (weak, nonatomic) IBOutlet UISwitch *switchB;
@property (weak, nonatomic) IBOutlet UISwitch *switchFelica;
@property (weak, nonatomic) IBOutlet UISwitch *switchMifare;
@property (weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property (weak, nonatomic) IBOutlet UILabel *libVersion;
@property (weak, nonatomic) IBOutlet UILabel *deviceID;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersion;
@property (weak, nonatomic) IBOutlet UILabel *softwareVersion;
@property (strong, nonatomic) IBOutlet UITableView *properTable;
@property (weak, nonatomic) IBOutlet UILabel *deviceUID;


-(IBAction)Connect:(id)sender;

@end
