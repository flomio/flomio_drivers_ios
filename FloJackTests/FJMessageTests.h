//
//  FJNDEFTests.h
//  FJNDEFTests
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FJMessage.h"
#import "FJNDEFMessage.h"
#import "FJNDEFRecord.h"


@interface FJMessageTests : SenTestCase {
    FJMessage *_flojackMessage;
}

- (void)testFJMessageWithSubOpcode;
- (void)testFJMessageWithSubOpcodeAndData;

@end
