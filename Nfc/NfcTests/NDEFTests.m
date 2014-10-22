//
//  NDEFTests.m
//  Flomio
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "NDEFTests.h"
#import "StringDisplay.h"

@implementation NDEFTests

- (void)setUp
{
    [super setUp];
}
    
- (void)tearDown
{
    [super tearDown];
}


#pragma mark NDEF Encoding / Decoding Tests

// NFC Task Launcher (two tasks, call + send text message 
// 2 NDEF Short Records: Well Known (URI), MIME (NTL)
/**
 Test NDEF parsing, encoding and decoding of two NDEF records.
 Record 1:
     TNF = TNF_WELL_KNOWN (0x01)
     RTD = RTD_URI (0x55)
     Payload = "http://www.ttag.be/m/04FAC9193E2580"
 Record 2:
     TNF = TNF_MIME_MEDIA (0x02)
     RTD = 
     Payload = 
 
 @return void
 */
- (void)testNDEFRecordParsingForTwoShortRecords
{
    int bytesLength = 65;
    UInt8 bytes[] = {-111, 1, 12, 85,
                    3, 116, 97, 103,
                    115, 46, 116, 111,
                    47, 110, 116, 108,
                    82, 3, 43, 110,
                    116, 108, 2, 101,
                    110, 90, 58, 56,
                    58, 84, 97, 115,
                    107, 32, 56, 59,
                    112, 58, 53, 54,
                    49, 51, 48, 57,
                    57, 51, 51, 52,
                    59, 111, 58, 53,
                    54, 49, 51, 48,
                    57, 57, 51, 51,
                    52, 58, 121, 101,
                    115};
    
    NSData *data = [[NSData alloc] initWithBytes:bytes length:bytesLength];
    _ndefRecords = [NDEFRecord parseData:data andIgnoreMbMe:FALSE];
    
    STAssertTrue(([_ndefRecords count] == 2)
                 , @"Incorrect number of NDEF Records");
}

@end
