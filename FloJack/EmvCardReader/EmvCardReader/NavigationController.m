//
//  File: NavigationController.m
//  Abstract: A UINavigationController subclass that always defers queries about
//  its preferred status bar style and supported interface orientations to its
//  child view controllers.
//
//  Created by Richard Grundy on 10/14/14.
//  Copyright (c) 2014 Flomio, Inc. All rights reserved.
//
#import "NavigationController.h"

@implementation NavigationController

//| ----------------------------------------------------------------------------
//  Defer returning the supported interface orientations to the navigation
//  controller's top-most view controller.
- (NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end
