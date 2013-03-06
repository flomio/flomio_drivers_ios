//
//  FJNDEFMessage.m
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//
//  NOTE:   This file is a port of Android.nfc.NdefMessage code found in the The Android Open Source Project.
//

#import "FJNDEFMessage.h"

@implementation FJNDEFMessage {
    NSArray     *_ndefRecords;
}

@synthesize ndefRecords = _ndefRecords;

- (id)initWithByteBuffer:(NSData *)byteBuffer {
    if (byteBuffer == nil)
        [NSException raise:@"Invalid value" format:@"Byte buffer is nil"];
    
    return [self initWithNdefRecords:[FJNDEFRecord parseData:byteBuffer andIgnoreMbMe:FALSE]];
}

- (id)initWithNdefRecord:(FJNDEFRecord *)ndefRecord {
    return [self initWithNdefRecords:[[NSArray alloc] initWithObjects:ndefRecord,nil]];
}

// Designated initializer
- (id)initWithNdefRecords:(NSArray *)ndefRecords {
    if (self = [super init]) {
        _ndefRecords = ndefRecords;
    }
    
    return self;
}

- (NSData *)asByteBuffer; {
    
    NSMutableData *messageByteBuffer = [[NSMutableData alloc] init];
    
    if (_ndefRecords == nil || [_ndefRecords count] == 0) {
        return [[NSData alloc] initWithData:messageByteBuffer];
    }
    
    [_ndefRecords enumerateObjectsUsingBlock:^(FJNDEFRecord *ndefRecord, NSUInteger i, BOOL *stop) {
        
        NSMutableData *ndefRecordData = [[NSMutableData alloc] initWithData:[ndefRecord asByteBuffer]];
        
        // Run checks on flag byte
        char flag[1];
        [ndefRecordData getBytes:flag length:1];
        
        /* Make sure the Message Begin flag is set only for the first record */
        [ndefRecordData getBytes:flag length:1];
        if (i == 0) {
            flag[0] |= kFlagMB;
            [ndefRecordData replaceBytesInRange:NSMakeRange(0, 1) withBytes:&flag[0]];
        }
        else {
            flag[0] &= ~kFlagMB;
            [ndefRecordData replaceBytesInRange:NSMakeRange(0, 1) withBytes:&flag[0]];
        }
        
        /* Make sure the Message End flag is set only for the last record */
        if (i == ([_ndefRecords count] - 1)) {
            flag[0] |= kFlagME;
            [ndefRecordData replaceBytesInRange:NSMakeRange(0, 1) withBytes:&flag[0]];
        }
        else {
            flag[0] &= ~kFlagME;
            [ndefRecordData replaceBytesInRange:NSMakeRange(0, 1) withBytes:&flag[0]];
        }
        
        [messageByteBuffer appendData:ndefRecordData];        
    }];

    return [[NSData alloc] initWithData:messageByteBuffer];
}

/*
 // Record 0
 [0] Flag Byte
 1001 0001 (0xD1)
 |||| ||
 |||| ||---> TNF = 001      // TNF_WELL_KNOWN = 0x01;
 |||| |----> IL = 0
 ||||
 ||||------>	SR = 1 		// short record
 |||------->	CF = 0
 ||-------->	ME = 1
 |--------->	MB = 1 		// message begin
 
 [1] Type Length
 0000 0001  (1)
 
 [2] Payload Length
 0000 1100 (12) 	// "(http://)tags.to/ntl", note this only applies to chunk 0
 
 [3] Type
 0101 0101 (85) 	// RTD_URI = {0x55};   // "U"s
 
 [4..15] Payload
 0000 0011 (3)	// "http://" 0x03
 116, 97, 103, 115, 46, 116, 111, 47, 110, 116, 108
 */

/**
 NDEF prefix encode the given url and return as an NSData object.
 
 @return NSData
 */
+ (FJNDEFMessage *)createURIWithSting:(NSString *)uriString {
    if (uriString == nil) {
        return nil;
    }
    FJNDEFRecord *uriRecord = [FJNDEFRecord createURIWithString:uriString];
    return [[FJNDEFMessage alloc] initWithNdefRecord:uriRecord];
}

@end
