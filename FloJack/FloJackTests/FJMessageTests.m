//
//  FJNDEFTests.m
//  FJNDEFTests
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FJMessageTests.h"
#import "NSData+FJStringDisplay.h"


@implementation FJMessageTests

- (void)setUp
{
    [super setUp];
}
    
- (void)tearDown
{   
    [super tearDown];
}


#pragma mark FJMessage Creation Tests

/**
Tests the parsing of a byte stream and creation of an FJMessage object.
    Message includes opcode, and subopcode. 
 
 @return void
*/
- (void)testFJMessageWithSubOpcode
{    
    NSData *ack_enable_msg = [NSData dataWithBytes:(UInt8[]){0x06, 0x04, 0x01, 0x03} length:4];
    
    _flojackMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_ACK_ENABLE_OP
                                                                andSubOpcode:FLOMIO_ENABLE
                                                                     andData:nil];
    
    XCTAssertTrue(([_flojackMessage.bytes isEqualToData:ack_enable_msg])
                 , @"FloJack Message parsed incorrectly.");
}

/**
 Tests the parsing of a byte stream and creation of an FJMessage object.
    Message includes opcode, subopcode, and data. 
 
 @return void
*/
- (void)testFJMessageWithSubOpcodeAndData
{
    NSData *inter_byte_delay_ipad2_msg = [NSData dataWithBytes:(UInt8[]){0x0C, 0x05, 0x00, 0x0C, 0x05} length:5];
    NSData *data = [NSData dataWithBytes:(UInt8[]){0x0C} length:1];
    
    _flojackMessage = [[FJMessage alloc] initWithMessageParameters:FLOMIO_COMMUNICATION_CONFIG_OP
                                                                andSubOpcode:FLOMIO_BYTE_DELAY
                                                                     andData:data];
    
    XCTAssertTrue(([_flojackMessage.bytes isEqualToData:inter_byte_delay_ipad2_msg])
                 , @"FloJack Message parsed incorrectly.");
}

@end
