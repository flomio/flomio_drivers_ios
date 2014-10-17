//
//  FTnfcConnectionTableViewController.m
//  FT_aR530Example
//
//  Created by yuanzhen on 14/6/12.
//  Copyright (c) 2014年 FTSafe. All rights reserved.
//

#import "FTnfcConnectionTableViewController.h"
#import "FTnfcTransmitViewController.h"

@interface FTnfcConnectionTableViewController ()
@property (strong, nonatomic) IBOutlet UITextField *txtTimeout;
@property (strong, nonatomic) IBOutlet UITextField *txtRetryCount;
@property (strong, nonatomic) IBOutlet UISwitch *switchTypeA;
@property (strong, nonatomic) IBOutlet UISwitch *switchTypeB;
@property (strong, nonatomic) IBOutlet UISwitch *switchTypeFelica;
@property (strong, nonatomic) IBOutlet UISwitch *switchTypeTopaz;
@property (strong, nonatomic) IBOutlet UISwitch *switchTypeMifare;

@end

@implementation FTnfcConnectionTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
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
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboard
{
    [_txtTimeout resignFirstResponder];
    [_txtRetryCount resignFirstResponder];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FTnfcTransmitViewController *destVC = segue.destinationViewController;
    Byte cardType = 0;
    if (_switchTypeA.isOn) {
        cardType |= A_CARD;
    }
    if (_switchTypeB.isOn) {
        cardType |= B_CARD;
    }
    if (_switchTypeFelica) {
        cardType |= Felica_CARD;
    }
    if (_switchTypeTopaz) {
        cardType |= Topaz_CARD;
    }
    destVC.cardType = cardType;
    destVC.retryCount = _txtRetryCount.text.intValue;
    destVC.timeout = _txtTimeout.text.intValue;
}



@end
