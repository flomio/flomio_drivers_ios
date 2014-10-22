//
//  FlomioMessageTests.h
//  Flomio
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FlomioMessage.h"
#import "NDEFMessage.h"
#import "NDEFRecord.h"


@interface FlomioMessageTests : SenTestCase {
    FlomioMessage *_flomioMessage;
}

- (void)testFlomioMessageWithSubOpcode;
- (void)testFlomioMessageWithSubOpcodeAndData;

@end
