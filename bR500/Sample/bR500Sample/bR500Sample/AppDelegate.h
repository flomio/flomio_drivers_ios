//
//  AppDelegate.h
//  bR500Sample
//
//  Created by 彭珊珊 on 16/1/20.
//  Copyright © 2016年 ftsafe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property float autoSizeScaleX;
@property float autoSizeScaleY;
+ (void)storyBoradAutoLay:(UIView *)allView;

@end

