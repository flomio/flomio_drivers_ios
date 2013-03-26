//
//  LoggingViewController.h
//  FloJack
//
//  Created by John Bullard on 3/25/13.
//  Copyright (c) 2013 John Bullard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJNFCAdapter.h"

@interface LoggingViewController : UIViewController <FJNFCAdapterDelegate>

@property (strong, nonatomic) IBOutlet UITextView *loggingTextView;

@end
