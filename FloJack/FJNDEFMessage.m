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

// NDEF flag mask: Message Begins
static const UInt8 kFlagMB = 0x80;

// NDEF flag mask: Message Ends
static const UInt8 kFlagME = 0x40;

- (id)initWithByteBuffer:(NSData *)byteBuffer {
    if (byteBuffer == nil)
        [NSException raise:@"Invalid value" format:@"Byte buffer is nil"];
    
    return [self initWithNdefRecords:[FJNDEFRecord parseData:byteBuffer andIgnoreMbMe:FALSE]];
}

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

@end
