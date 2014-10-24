//
//  ViewController.m
//  SoundCheck
//
//  Created by Boris  on 10/21/14.
//  Copyright (c) 2014 LLT. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

-(IBAction)play:(id)sender {
    // Construct URL to sound file
    
    //[self configureAVAudioSession];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"notification" ofType:@"mp3"];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    NSError *error;
    // Create audio player object and initialize with URL to sound
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    self.audioPlayer.numberOfLoops = 1;
    
    if (self.audioPlayer == nil)
        NSLog(@"%@",[error description]);
    else
        [self.audioPlayer play];

    
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
