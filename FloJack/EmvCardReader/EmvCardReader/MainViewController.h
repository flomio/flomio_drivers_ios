//
//  MainViewController.h
//  EMVCardReader
//
//  Created by Boris  on 10/17/14.
//  Copyright (c) 2014 LLT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftMenuView.h"

@interface MainViewController : UIViewController {
    
    LeftMenuView *leftMenu;
    CGPoint startPosition;
}

@end
