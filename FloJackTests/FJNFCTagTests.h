//
//  FJNFCTagTests.h
//  FJNDEFTests
//
//  Created by John Bullard on 4/28/13.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FJMessage.h"
#import "FJNDEFMessage.h"
#import "FJNDEFRecord.h"
#import "FJNFCTag.h"

/*
 Collection of unit tests for FJNFCTag object. 
 Purposefuly excludes testing NDEF Message and NDEF Record objects. We have dedicated tests for that. 
 
 */
@interface FJNFCTagTests : SenTestCase

@property NSMutableArray *tagTestData;

@end
