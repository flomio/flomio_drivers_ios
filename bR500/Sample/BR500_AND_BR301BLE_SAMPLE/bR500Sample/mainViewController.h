//
//  mainViewController.h
//  bR500Sample
//
//  Created by 彭珊珊 on 16/1/20.
//  Copyright © 2016年 ftsafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "winscard.h"
#import "ReaderInterface.h"
#import "wintypes.h"
#import "ft301u.h"


@interface mainViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ReaderInterfaceDelegate>
@property (nonatomic,strong) IBOutlet UITextView *atrTextView;
@property (nonatomic,strong) IBOutlet UITextView *logTextView;
@property (nonatomic,strong) IBOutlet UITextField *apduTextField;
@property (nonatomic,strong) IBOutlet UISwitch *cardStatus;
@property (nonatomic,strong) IBOutlet UITableView *commandListView;
@property (nonatomic,strong) IBOutlet UILabel *softVersion;
@property (nonatomic,strong) IBOutlet UILabel *SDKVersion;
@property (nonatomic,strong) IBOutlet UILabel *firmVersion;
@property (nonatomic,strong) NSString *currentReaderName;

-(IBAction)connectCard:(id)sender;
-(IBAction)disConnectCard:(id)sender;
-(IBAction)sendCommand:(id)sender;
-(IBAction)dispostList:(id)sender;
-(IBAction)writeReaderUID:(id)sender;
-(IBAction)readReaderUID:(id)sender;
-(IBAction)eraseReaderUID:(id)sender;
-(IBAction)writeReaderFlash:(id)sender;
-(IBAction)readReaderFlash:(id)sender;
-(IBAction)getCardStatus:(id)sender;
-(IBAction)getReaderHID:(id)sender;

-(IBAction)testButtonPressed:(id)sender;
-(IBAction)clearLog:(id)sender;
@end
