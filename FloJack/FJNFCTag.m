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

- (id)initWithUid:(NSData *)theUid;{
    return [self initWithUid:theUid andData:nil andType:UNKNOWN_TAG_TYPE];;
}

- (id)initWithUid:(NSData *)theUid andData:(NSData *)theData; {
    return [self initWithUid:theUid andData:theData andType:UNKNOWN_TAG_TYPE];
}

- (id)initWithUid:(NSData *)theUid andData:(NSData *)theData andType:(UInt8)type; {
    self = [super init];
    if(self) {
        _uid = [theUid copy];
        _data = [theData copy];
        _nfcForumType = type;
        _ndefMessage = [self parseMemoryForNdefMessage];
    }
    return self;
}

- (FJNDEFMessage *)parseMemoryForNdefMessage; {
    switch (_nfcForumType) {
        case NFC_FORUM_TYPE_1:
        case NFC_FORUM_TYPE_2:
            return [self type2ParseMemoryForNdefMessage];
        case NFC_FORUM_TYPE_3:
        case NFC_FORUM_TYPE_4:
        default:
            return nil;
    }
}

- (FJNDEFMessage *)type2ParseMemoryForNdefMessage; {
    if (_data == nil || _uid == nil) {
        return nil;
    }
    
    // _data contains UID + NDEF payload only
    UInt8 ndefBegin = _uid.length;
    UInt8 ndefLen = (_data.length - _uid.length);
    
    NSData *ndefData = [_data subdataWithRange:NSMakeRange(ndefBegin, ndefLen)];
    
    NSArray *ndefRecords = [FJNDEFRecord parseData:ndefData andIgnoreMbMe:FALSE];
    if (ndefRecords != nil) {
        return [[FJNDEFMessage alloc] initWithNdefRecords:ndefRecords];
    }
    
    
    // _data contains full data payload
    if ( _data.length < 48) {
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
    UInt8 ndefTLVLocation = self.type2ParseMemoryForNdefTLVLocation;
    if (ndefTLVLocation == 0) {
        NSLog(@"NDEF TLV not found");
        return nil;
    }
    
    UInt8 ndefTLVLength;
    [_data getBytes:&ndefTLVLength range:NSMakeRange(ndefTLVLocation + 1, 1)];
        
    if (ndefTLVLength > 0 && (_data.length >= (ndefTLVLocation + 2 + ndefTLVLength))) {
        ndefData = [_data subdataWithRange:NSMakeRange(ndefTLVLocation + 2, ndefTLVLength)];
        
        ndefRecords = [FJNDEFRecord parseData:ndefData andIgnoreMbMe:FALSE];
        return [[FJNDEFMessage alloc] initWithNdefRecords:ndefRecords];
    }
    else {
        NSLog(@"NDEF TLV found but length is zero");
        return nil;
    }
}

- (UInt8)type2ParseMemoryForNdefTLVLocation; {
    char *dataPtr = (char *) _data.bytes;

	for (int i = 16; i < _data.length; i++) {
		if (dataPtr[i] == 0x00) {
			// NULL TLV. No (L) or (V) present
			continue;
		}
		else if (dataPtr[i] == 0x01) {
			// Lock Control TLV. (T)=0x01, (L)=0x03
			i += 1;
			i += 3;
			continue;
		}
		else if (dataPtr[i] == 0x02) {
			// Memory Control TLV. (T)=0x02, (L)=0x03
			i += 1;
			i += 3;
			continue;
		}
		else if (dataPtr[i] == 0x03) {
			// NDEF TLV. (T)=0x03, (L)=0x03
			return i;
		}
		else if (dataPtr[i] == 0xFD) {
			// Proprietary TLV. (T)=variable, (L)=variable
			if (dataPtr[i+1] < 0xFF) {
				// Single byte format
				i += 1;
				i += dataPtr[i+1];
			}
			else {
				// Three byte format (first byte == 0xFF)
				UInt16 length = dataPtr[i+2] | dataPtr[i+3];
				i += 3;
				i += length;
			}
		}
		else if (dataPtr[i] == 0xFE) {
			// Terminator TLV. (T)=N/A, (L)=N/A
			continue;
		}
	}
	return nil;
}

@end
