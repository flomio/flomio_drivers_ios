//
//  FJNDEFTests.m
//  FJNDEFTests
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FJNDEFURITests.h"
#import "NSData+FJStringDisplay.h"

@implementation FJNDEFURITests

@synthesize ndefTestData = _ndefTestData;

- (void)setUp
{
    [super setUp];
    self.ndefTestData = [[NSMutableArray alloc] initWithCapacity:2];
    
    /**
     Test Dataset 1:
     TNF = TNF_WELL_KNOWN (0x01), RTD = RTD_URI (0x55)
     Payload = "http://www.ttag.be/m/04FAC9193E2580"
     */
    int bytesLengthT1 = 29;
    UInt8 bytesT1[] = {0xd1, 0x01, 0x19, 0x55,
        0x01, 0x74, 0x74, 0x61,
        0x67, 0x2e, 0x62, 0x65,
        0x2f, 0x6d, 0x2f, 0x30,
        0x34, 0x46, 0x41, 0x43,
        0x39, 0x31, 0x39, 0x33,
        0x45, 0x32, 0x35, 0x38,
        0x30};
    NSURL *urlT1 = [[NSURL alloc] initWithString:@"http://www.ttag.be/m/04FAC9193E2580"];
    NSNumber *ndefRecordCountT1 = [NSNumber numberWithInt:1];
    
    
    NSData *ndefMessageDataT1 = [[NSData alloc] initWithBytes:bytesT1 length:bytesLengthT1];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                ndefMessageDataT1,      @"ndefData",
                                ndefRecordCountT1,      @"ndefRecordCount",
                                urlT1,                  @"url"
                                , nil];
    [self.ndefTestData addObject:dict];
    
    /**
     Test Dataset 2:
     TNF = TNF_WELL_KNOWN (0x01), RTD = RTD_URI (0x55)
     Payload = "http://www.flomio.com"
     */
    // Type 2 tag memory
    int bytesLengthT2 = 15;
    UInt8 bytesT2[] = {
        0xd1, 0x01, 0x0b, 0x55,
        0x01, 0x66, 0x6c, 0x6f,
        0x6d, 0x69, 0x6f, 0x2e,
        0x63, 0x6f, 0x6d
    };
    
    NSURL *urlT2 = [[NSURL alloc] initWithString:@"http://www.flomio.com"];
    NSNumber *ndefRecordCountT2 = [NSNumber numberWithInt:1];
    
    NSData *ndefMessageDataT2 = [[NSData alloc] initWithBytes:bytesT2 length:bytesLengthT2];
    NSDictionary *dictT2 = [NSDictionary dictionaryWithObjectsAndKeys:
                          ndefMessageDataT2,        @"ndefData",
                          ndefRecordCountT2,        @"ndefRecordCount",
                          urlT2,                    @"url"
                          , nil];
    [self.ndefTestData addObject:dictT2];
}

- (void)testFJNDEFMessageDataDecoding
{
    for(id item in self.ndefTestData) {
        NSData *ndefData = [item objectForKey:@"ndefData"];
        NSNumber *ndefRecordCount = [item objectForKey:@"ndefRecordCount"];
        
        FJNDEFMessage *ndefMessage = [[FJNDEFMessage alloc] initWithByteBuffer:ndefData];
        NSData *ndefMessageDataDecoded = [ndefMessage asByteBuffer];
        
        STAssertTrue(([ndefData isEqualToData:ndefMessageDataDecoded])
                        , @"FJNDEFMessage decoded data is incorrect.");
        STAssertTrue((ndefMessage.ndefRecords.count == ndefRecordCount.intValue)
                        , @"FJNDEFMessage has incorrect number of NDEF records.");
    }
}

- (void)testFJNDEFRecordDataDecoding
{
    for(id item in self.ndefTestData) {
        NSData *ndefData = [item objectForKey:@"ndefData"];
        NSNumber *ndefRecordCount = [item objectForKey:@"ndefRecordCount"];
        NSURL *url = [item objectForKey:@"url"];
        
        NSArray *ndefRecords = [FJNDEFRecord parseData:ndefData andIgnoreMbMe:FALSE];
        FJNDEFRecord *ndefRecord = [ndefRecords objectAtIndexedSubscript:0];
        
        STAssertTrue(([ndefRecords count] == ndefRecordCount.intValue)
                     , @"FJNDEFRecord has incorrect number of NDEF Records.");
        STAssertTrue(([ndefRecord.asByteBuffer isEqualToData:ndefData])
                     , @"FJNDEFRecord decoded byte stream incorrect.");
        STAssertTrue(([ndefRecord.getUriFromPayload isEqual:url])
                     , @"FJNDEFRecord decoded URI is incorrect.");
    }
}

- (void)testFJNDEFMessageDataEncoding
{    
    for(id item in self.ndefTestData) {
        NSData *ndefData = [item objectForKey:@"ndefData"];
        NSNumber *ndefRecordCount = [item objectForKey:@"ndefRecordCount"];
        NSURL *url = [item objectForKey:@"url"];
        
        FJNDEFMessage *ndefMessage = [FJNDEFMessage createURIWithSting:url.absoluteString];
                
        STAssertTrue((ndefMessage.ndefRecords.count == ndefRecordCount.intValue)
                     , @"FJNDEFMessage encoded incorrect number of NDEF Records.");
        STAssertTrue(([ndefMessage.asByteBuffer isEqualToData:ndefData])
                     , @"FJNDEFMessage encoded byte stream incorrect.");
        
    }
}

- (void)testFJNDEFRecordDataEncoding
{
    for(id item in self.ndefTestData) {
        NSData *ndefData = [item objectForKey:@"ndefData"];
        NSURL *url = [item objectForKey:@"url"];
        
        FJNDEFRecord *ndefRecord = [FJNDEFRecord createURIWithString:url.absoluteString];
        
        STAssertTrue(([ndefRecord.asByteBuffer isEqualToData:ndefData])
                     , @"FJNDEFRecord decoded byte stream incorrect.");
        STAssertTrue(([ndefRecord.getUriFromPayload isEqual:url])
                     , @"FJNDEFRecord decoded URI is incorrect.");
        
        ndefRecord = [FJNDEFRecord createURIWithURL:url];
        
        STAssertTrue(([ndefRecord.asByteBuffer isEqualToData:ndefData])
                     , @"FJNDEFRecord decoded byte stream incorrect.");
        STAssertTrue(([ndefRecord.getUriFromPayload isEqual:url])
                     , @"FJNDEFRecord decoded URI is incorrect.");
    }
}

- (void)tearDown
{
    [super tearDown];
}

@end
