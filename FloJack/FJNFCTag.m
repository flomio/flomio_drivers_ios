//
//  FJNFCTag.m
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FJNFCTag.h"

@implementation FJNFCTag {
    NSData      *_uid;
    NSData      *_data;    
}

@synthesize uid = _uid;
@synthesize data = _data;
@synthesize ndefMessage = _ndefMessage;
@synthesize nfcForumType = _nfcForumType;


// Designated initializer
- (id)initWithUid:(NSData *)theUid andData:(NSData *)theData; {
    self = [super init];
    if(self) {
        _uid = [theUid copy];
        _data = [theData copy];
        
        _nfcForumType = NFC_FORUM_TYPE_2;
        _ndefMessage = [self parseMemoryForNdefMessage];
        
        //NSArray *ndefRecords = [FJNDEFRecord parseData:_data andIgnoreMbMe:FALSE];
        //_ndefMessage = [[FJNDEFMessage alloc] initWithNdefRecords:ndefRecords];
        
    }
    return self;
}

- (id)initWithUid:(NSData *)theUid;{
    return [self initWithUid:theUid andData:nil];
}

- (FJNDEFMessage *)parseMemoryForNdefMessage; {
    switch (_nfcForumType) {
        case NFC_FORUM_TYPE_1:
        case NFC_FORUM_TYPE_2:
            return [self type2ParseMemoryForNdefMessage];
        case NFC_FORUM_TYPE_3:
        case NFC_FORUM_TYPE_4:
        default:
            return [self type2ParseMemoryForNdefMessage];           
        
    }
}

- (FJNDEFMessage *)type2ParseMemoryForNdefMessage; {
    if (_data == nil || _data.length < 48) {
        return nil;
    }    
    
    //check for errors in capability container
    UInt8 ccMagicValue;
    [_data getBytes:&ccMagicValue range:NSMakeRange(12, 1)];
    
    UInt8 ccVersion;
    [_data getBytes:&ccVersion range:NSMakeRange(13, 1)];
    
//    UInt8 ccDataLen;
//    [_data getBytes:&ccDataLen range:NSMakeRange(14, 1)];
//    ccDataLen *= 8;
    
    UInt8 ccReadWriteAbility;
    [_data getBytes:&ccReadWriteAbility range:NSMakeRange(15, 1)];
    
    if (ccMagicValue != 0xE1) {
        NSLog(@"CC Magic Value not equal to 0xE1");
        return nil;
    }
    else if (ccVersion != 0x10) {
        NSLog(@"CC Version not euqal to 1.0");
        return nil;        
    }
//    else if (( 0x0 | 4 >> ccReadWriteAbility) != 0x00) {
//        NSLog(@"CC Read Access not available");
//        return nil;        
//    }
    
    
    //find mandatory NDEF Message TLV
    UInt8 ndefTLVType = 0x03;
    NSData *ndefTLV = [[NSData alloc] initWithBytes:&ndefTLVType length:1];
    NSRange ndefTLVRange = [_data rangeOfData:ndefTLV options:nil range:NSMakeRange(16, _data.length - 17)];
    
    if (ndefTLVRange.location == NSNotFound) {
        NSLog(@"NDEF TLV not found");
        return nil;
    }
    
    UInt8 ndefTLVLength;
    [_data getBytes:&ndefTLVLength range:NSMakeRange(ndefTLVRange.location + 1, 1)];
    
    if (ndefTLVLength > 0) {
        NSData *ndefData = [_data subdataWithRange:NSMakeRange(ndefTLVRange.location + 2, ndefTLVLength)];
        
        NSArray *ndefRecords = [FJNDEFRecord parseData:ndefData andIgnoreMbMe:FALSE];
        return [[FJNDEFMessage alloc] initWithNdefRecords:ndefRecords];
    }
    else {
        NSLog(@"NDEF TLV found but length is zero");
        return nil;
    }
}

@end
