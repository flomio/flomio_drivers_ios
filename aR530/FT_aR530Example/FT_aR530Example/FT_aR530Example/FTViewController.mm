//
//  FTViewController.m
//  FT_aR530Example
//
//  Created by yuanzhen on 14/6/12.
//  Copyright (c) 2014年 FTSafe. All rights reserved.
//

#import "FTViewController.h"
#import "FTDeviceNotFoundViewController.h"
#import "include/FT_aR530.h"

@interface FTViewController ()
@property (strong, nonatomic) FTDeviceNotFoundViewController *vcWarning;

@end


extern bool isShowMifare;

bool isOut = true;

static void FTaudio_Event(unsigned char is_inserted,void* user_data)
{
    FTViewController *viewContorller = (__bridge FTViewController *)user_data;
    
    if(is_inserted) {
        [viewContorller eventHandler:true];
    }else {
        [viewContorller eventHandler:false];
    }
}

@implementation FTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _vcWarning = [self.storyboard instantiateViewControllerWithIdentifier:SID_DEVICE_NOTFOUND];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(RegisterMonitor) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)eventHandler:(bool) isInsert
{
    if(isInsert == true) {
        
        if(isOut == true) {
            isOut = false;
            [_vcWarning dismissViewControllerAnimated:YES completion:^(){}];
        }
        
    }else {
        
        if(isOut == false) {
            isOut = true;
            [self presentViewController:_vcWarning animated:YES completion:^(void){}];
        }
        NSLog(@"out");
    }
}



-(void)RegisterMonitor
{
    FTRegistMonitor((NOTIFY_RECEIVER*)&FTaudio_Event, (__bridge void*)self);
    
    if(isOut == true) {
        [self presentViewController:_vcWarning animated:YES completion:^(void){}];
    }
}
@end
