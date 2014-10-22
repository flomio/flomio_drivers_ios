//
//  FlomioMessageTests.m
//  Flomio
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FlomioMessageTests.h"
#import "StringDisplay.h"


@implementation FlomioMessageTests

- (void)setUp
{
    [super setUp];
}
    
- (void)tearDown
{   
    [super tearDown];
}


#pragma mark FlomioMessage Creation Tests

/**
Tests the parsing of a byte stream and creation of an FlomioMessage object.
    Message includes opcode, and subopcode. 
 
 @return void
*/
- (void)testFJMessageWithSubOpcode
{    
    NSData *ack_enable_msg = [NSData dataWithBytes:(UInt8[]){0x06, 0x04, 0x01, 0x03} length:4];
    
    _flomioMessage = [[FlomioMessage alloc] initWithMessageParameters:FLOMIO_ACK_ENABLE_OP
                                                                andSubOpcode:FLOMIO_ENABLE
                                                                     andData:nil];
    
    STAssertTrue(([_flomioMessage.bytes isEqualToData:ack_enable_msg])
                 , @"FloJack Message parsed incorrectly.");
}

/**
 Tests the parsing of a byte stream and creation of an FlomioMessage object.
    Message includes opcode, subopcode, and data. 
 
 @return void
*/
- (void)testFlomioMessageWithSubOpcodeAndData
{
    NSData *inter_byte_delay_ipad2_msg = [NSData dataWithBytes:(UInt8[]){0x0C, 0x05, 0x00, 0x0C, 0x05} length:5];
    NSData *data = [NSData dataWithBytes:(UInt8[]){0x0C} length:1];
    
    _flomioMessage = [[FlomioMessage alloc] initWithMessageParameters:FLOMIO_COMMUNICATION_CONFIG_OP
                                                                andSubOpcode:FLOMIO_BYTE_DELAY
                                                                     andData:data];
    
    STAssertTrue(([_flomioMessage.bytes isEqualToData:inter_byte_delay_ipad2_msg])
                 , @"FloJack Message parsed incorrectly.");
}

@end
