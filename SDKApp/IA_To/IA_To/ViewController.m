//
//  ViewController.m
//  IA_To
//
//  Created by Boris  on 10/27/14.
//  Copyright (c) 2014 LLT. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize textField;

- (IBAction)postToApp:(id)sender {
    
    
    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"flomio://localhost?string=%@",textField.text]];
    [[UIApplication sharedApplication] openURL:myURL];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
