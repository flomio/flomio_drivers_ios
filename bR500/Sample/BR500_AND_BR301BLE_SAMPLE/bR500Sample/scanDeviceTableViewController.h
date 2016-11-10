//
//  scanDeviceTableViewController.h
//  bR500Sample
//
//  Created by 彭珊珊 on 16/1/20.
//  Copyright © 2016年 ftsafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainViewController.h"

@interface scanDeviceTableViewController : UITableViewController<ReaderInterfaceDelegate>
@property (nonatomic,strong) NSMutableArray *deviceListArray;
@property (nonatomic,strong) ReaderInterface *readerInfo;
@property (nonatomic,strong) NSString *selectReaderName;

@end
