//
//  FTViewController.h
//  FT_aR530Example
//
//  Created by yuanzhen on 14/6/12.
//  Copyright (c) 2014年 FTSafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "include/FT_aR530.h"



@interface FTViewController : UITableViewController

-(void)eventHandler:(bool) isInsert;
@end
