//
//  LeftMenuView.m
//  EMVCardReader
//
//  Created by Boris  on 10/17/14.
//  Copyright (c) 2014 LLT. All rights reserved.
//

#import "LeftMenuView.h"

@implementation LeftMenuView

@synthesize isOut, navigationController;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)open {
    
    if (self.isOut != [NSNumber numberWithBool:YES]) {
        
        [UIView beginAnimations:@"foo" context:nil];
        [UIView setAnimationDuration:1];
        self.frame = CGRectMake(self.frame.origin.x + self.frame.size.width/2, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        [UIView commitAnimations];
        
        self.isOut = [NSNumber numberWithBool:YES];
    }
    
    
}

-(void)close {
    
    
    if (self.isOut != [NSNumber numberWithBool:NO]) {
        [UIView beginAnimations:@"foo" context:nil];
        [UIView setAnimationDuration:1];
        self.frame = CGRectMake(self.frame.origin.x - self.frame.size.width/2, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        [UIView commitAnimations];
        
        self.isOut = [NSNumber numberWithBool:NO];
    }

}

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        [self setButtons];
        isOut = [NSNumber numberWithBool:NO];
    }
    return self;
}

- (void)setButtons {

    
    UIButton *cardDetailsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cardDetailsButton addTarget:self
               action:@selector(aMethod:)
     forControlEvents:UIControlEventTouchUpInside];
    [cardDetailsButton setTitle:@"Card Details" forState:UIControlStateNormal];
    cardDetailsButton.frame = CGRectMake(200, 90.0, 160.0, 40.0);
    cardDetailsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self addSubview:cardDetailsButton];
    
    UIButton *configurationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [configurationButton addTarget:self
                          action:@selector(goToConfiguration:)
                forControlEvents:UIControlEventTouchUpInside];
    [configurationButton setTitle:@"Configuration" forState:UIControlStateNormal];
    configurationButton.frame = CGRectMake(200, 140.0, 160.0, 40.0);
    configurationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self addSubview:configurationButton];
    
    UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [aboutButton addTarget:self
                          action:@selector(goToAbout:)
                forControlEvents:UIControlEventTouchUpInside];
    [aboutButton setTitle:@"About" forState:UIControlStateNormal];
    aboutButton.frame = CGRectMake(200, 190.0, 160.0, 40.0);
    aboutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self addSubview:aboutButton];
}

- (IBAction)goToConfiguration:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"configuration"];
    [navigationController pushViewController:cvc animated:YES];
    
}

- (IBAction)goToAbout:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"about"];
    [navigationController pushViewController:avc animated:YES];
    
}

@end
