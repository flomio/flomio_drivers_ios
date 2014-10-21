//
//  TagTests.h
//  Flomio
//
//  Created by John Bullard on 4/28/13.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FlomioMessage.h"
#import "NDEFMessage.h"
#import "NDEFRecord.h"
#import "Tag.h"

/*
 Collection of unit tests for Tag object. 
 Purposefuly excludes testing NDEF Message and NDEF Record objects. We have dedicated tests for that. 
 
 */
@interface NFCTagTests : SenTestCase

@property NSMutableArray *tagTestData;

@end
