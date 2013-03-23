//
//  FJNDEFTests.m
//  FJNDEFTests
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FJNDEFTests.h"
#import "NSData+FJStringDisplay.h"

@implementation FJNDEFTests

- (void)setUp
{
    [super setUp];
}
    
- (void)tearDown
{
    [super tearDown];
}


#pragma mark NDEF Encoding / Decoding Tests

/**
Test NDEF parsing, encoding and decoding of a single NDEF record.
Record 1:
    TNF = TNF_WELL_KNOWN (0x01)
    RTD = RTD_URI (0x55)
    Payload = "http://www.ttag.be/m/04FAC9193E2580"
 
 @return void
 */
- (void)testFJNDEFMessageParsing
{    
    int bytesLength = 29;
    UInt8 bytes[] = {0xd1, 0x01, 0x19, 0x55,
                        0x01, 0x74, 0x74, 0x61,
                        0x67, 0x2e, 0x62, 0x65,
                        0x2f, 0x6d, 0x2f, 0x30,
                        0x34, 0x46, 0x41, 0x43,
                        0x39, 0x31, 0x39, 0x33,
                        0x45, 0x32, 0x35, 0x38,
                        0x30};
    
    
    NSData *ndefMessageData = [[NSData alloc] initWithBytes:bytes length:bytesLength];
    FJNDEFMessage *ndefMessage = [[FJNDEFMessage alloc] initWithByteBuffer:ndefMessageData];
    NSData *ndefMessageDataDecoded = [ndefMessage asByteBuffer];
    
    STAssertTrue(([ndefMessageData isEqualToData:ndefMessageDataDecoded])
                 , @"Decoded NDEF record incorrect.");
    STAssertTrue((ndefMessage.ndefRecords.count == 1)
                 , @"Incorrect number of NDEF records.");
}

/**
 Test NDEF parsing, encoding and decoding of a single NDEF record.
 Record 1:
     TNF = TNF_WELL_KNOWN (0x01)
     RTD = RTD_URI (0x55)
     Payload = "http://www.ttag.be/m/04FAC9193E2580"
 
 @return void
 */
- (void)testFJNDEFRecordParsingForOneShortRecord
{
    int bytesLength = 29;
    UInt8 bytes[] = {0xd1, 0x01, 0x19, 0x55,
                        0x01, 0x74, 0x74, 0x61,
                        0x67, 0x2e, 0x62, 0x65,
                        0x2f, 0x6d, 0x2f, 0x30,
                        0x34, 0x46, 0x41, 0x43,
                        0x39, 0x31, 0x39, 0x33,
                        0x45, 0x32, 0x35, 0x38,
                        0x30};
    
    NSData *data = [[NSData alloc] initWithBytes:bytes length:bytesLength];                  
    _ndefRecords = [FJNDEFRecord parseData:data andIgnoreMbMe:FALSE];
    
    STAssertTrue(([_ndefRecords count] == 1)
                 , @"Incorrect number of NDEF Records.");
    
    FJNDEFRecord *ndefRecord = [_ndefRecords objectAtIndexedSubscript:0];
    STAssertTrue(([_ndefRecords count] == 1)
                 , @"Incorrect number of NDEF Records.");
    
    STAssertTrue(([ndefRecord.asByteBuffer isEqualToData:data])
                 , @"Decoded byte stream incorrect.");
    
    NSURL *assertUrl = [[NSURL alloc] initWithString:@"http://www.ttag.be/m/04FAC9193E2580"];
    STAssertTrue(([ndefRecord.getUriFromPayload isEqual:assertUrl])
                 , @"Decoded URI is incorrect.");
}

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
- (void)testFJNDEFRecordParsingForTwoShortRecords
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
    _ndefRecords = [FJNDEFRecord parseData:data andIgnoreMbMe:FALSE];
    
    STAssertTrue(([_ndefRecords count] == 2)
                 , @"Incorrect number of NDEF Records");
}

/**
 Test NDEF parsing, encoding and decoding of two NDEF records.
    Type 2 Tag. Dynamic Memory. Lock TLV, NDEF TLV.
     Record 1:
     TNF = TNF_WELL_KNOWN (0x01)
     RTD = RTD_URI (0x55)
     Payload = "mailto://john%40flomio.com?subject=hi&amp;body=hey%20there%20"
 
 @return void
 */
- (void)testFJNDEFMessageType2ParseMemoryParsing
{
    // Type 2 tag memory
    int memoryLength = 168;
    UInt8 memoryBytes[] = {
        0x04, 0xba, 0xec, 0xda,
        0x72, 0xb9, 0x29, 0x80,
        0x62, 0x48, 0x00, 0x00,
        0xe1, 0x10, 0x12, 0x00,
        0x01, 0x03, 0xa0, 0x10,
        0x44, 0x03, 0x35, 0xd1, // NDEF TLV: 0x03-->(T),0x35-->(V),0xd1 -->(V)
        0x01, 0x31, 0x55, 0x06,
        0x6a, 0x6f, 0x68, 0x6e,
        0x25, 0x34, 0x30, 0x66,
        0x6c, 0x6f, 0x6d, 0x69,
        0x6f, 0x2e, 0x63, 0x6f,
        0x6d, 0x3f, 0x73, 0x75,
        0x62, 0x6a, 0x65, 0x63,
        0x74, 0x3d, 0x68, 0x69,
        0x26, 0x62, 0x6f, 0x64,
        0x79, 0x3d, 0x68, 0x65,
        0x79, 0x25, 0x32, 0x30,
        0x74, 0x68, 0x65, 0x72,
        0x65, 0x25, 0x32, 0x30,
        0xfe, 0x00, 0x00, 0x30,
        0x52, 0x45, 0x46, 0x3a,
        0x61, 0x74, 0x2d, 0x73,
        0x76, 0x63, 0x2d, 0x76,
        0x63, 0x73, 0x2d, 0x73,
        0x74, 0x61, 0x66, 0x66,
        0x31, 0x40, 0x75, 0x66,
        0x6c, 0x2e, 0x65, 0x64,
        0x75, 0x0d, 0x0a, 0x45,
        0x4e, 0x44, 0x3a, 0x56,
        0x43, 0x41, 0x52, 0x44,
        0x0d, 0x0a, 0xfe, 0x00,
        0xfe, 0x00, 0x00, 0x0a,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
    };
    NSData *uid = [[NSData alloc] initWithBytes:memoryBytes length:8];
    NSData *memory = [[NSData alloc] initWithBytes:memoryBytes length:memoryLength];
    NSData *ndefMessage = [[NSData alloc] initWithBytes:(memoryBytes + 23) length:0x35];
    
    
    FJNFCTag *tag = [[FJNFCTag alloc] initWithUid:uid andData:memory];
    FJNDEFMessage *parsedNdefMessage = [tag parseMemoryForNdefMessage];
    
   // STAssertTrue(([parsedNdefMessage.asByteBuffer isEqualToData:ndefMessage])
    //             , @"NDEF Message not parsed properly from Type 2 Dynamic Memory");
}

@end
