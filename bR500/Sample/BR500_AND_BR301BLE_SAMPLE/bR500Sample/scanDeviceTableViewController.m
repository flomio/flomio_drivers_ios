//
//  scanDeviceTableViewController.m
//  bR500Sample
//
//  Created by 彭珊珊 on 16/1/20.
//  Copyright © 2016年 ftsafe. All rights reserved.
//

#import "scanDeviceTableViewController.h"
#import "indicate.h"
@interface scanDeviceTableViewController ()
{
    __block indicate *indicateView;
}
@end

SCARDCONTEXT gContxtHandle;
@implementation scanDeviceTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    _deviceListArray = [[NSMutableArray alloc] init];
    _readerInfo = [[ReaderInterface alloc] init];
    [_readerInfo setDelegate:self];
    [self.tableView  reloadData];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"bR500";
}

/**
 *  Display buffer
 */
-(void)createIndicateView
{
    if (indicateView == nil) {
        indicateView = [[indicate alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 100.0f)];
        indicateView.center = self.view.center;
        [self.view addSubview:indicateView];
    }else{
        indicateView.hidden = NO;
    }
    
    self.tableView.userInteractionEnabled = NO;
}

/**
 *  Hide the frame buffer 
 */
-(void)hidIndicateView
{
    indicateView.hidden = YES;
    self.tableView.userInteractionEnabled = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - readerInterfaceDelegate
-(void)findPeripheralReader:(NSString *)readerName{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createIndicateView];
    });
    
    if (_deviceListArray == nil) {
        _deviceListArray = [[NSMutableArray alloc] init];
    }
    
    if ([readerName length] == 0) {
        return;
    }
    
    for (int i = 0; i < [_deviceListArray count]; i++) {
        if ([_deviceListArray[i] isEqualToString:readerName]) {
            return;
        }
    }
    
    [_deviceListArray addObject:readerName];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self hidIndicateView];
    });
    
}

-(void)readerInterfaceDidChange:(BOOL)attached
{
    if (attached) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hidIndicateView];
            [self performSegueWithIdentifier:@"reader_attatch" sender:self];
        });
    }else{
        
        for (NSString *deviceName in _deviceListArray) {
            if ([deviceName isEqualToString:_selectReaderName]) {
                [_deviceListArray removeObject:deviceName];
                break;
            }
        }
        //Update list
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self hidIndicateView];
        });
    }

}

-(void)cardInterfaceDidDetach:(BOOL)attached
{
 
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_deviceListArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"scanDeviceList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = _deviceListArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self createIndicateView];
    _selectReaderName =  _deviceListArray[indexPath.row];
    [_readerInfo connectPeripheralReader:_deviceListArray[indexPath.row]];
    
}

#pragma mark - stroyboard
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
   
    if ([identifier isEqualToString:@"reader_attatch"]) {
        return NO;
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    mainViewController *controller = segue.destinationViewController;
    controller.currentReaderName = _selectReaderName;
}

@end
