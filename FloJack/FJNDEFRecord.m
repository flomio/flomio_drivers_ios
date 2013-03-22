//
//  FJNDEFRecord.m
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//
//  NOTE:   This file is a port of Android.nfc.NdefRecord code found in the The Android Open Source Project.
//

#import "FJNDEFRecord.h"
#import "Logging.h"

@implementation FJNDEFRecord {
    char        flags_;
}

@synthesize tnf = _tnf;
@synthesize type = _type;
@synthesize theId = _theId;
@synthesize payload = _payload;

+(void)initialize; {
    kRTDAlternativeCarrier = [NSData dataWithBytes:(UInt8[]){0x61, 0x63} length:2];
    kRTDHandoverCarrier = [NSData dataWithBytes:(UInt8[]){0x48, 0x63} length:2];
    kRTDHandoverRequest = [NSData dataWithBytes:(UInt8[]){0x48, 0x72} length:2];
    kRTDHandoverSelect = [NSData dataWithBytes:(UInt8[]){0x48, 0x73} length:2];
    kRTDSmartPost = [NSData dataWithBytes:(UInt8[]){0x53, 0x70} length:2];
    kRTDURI = [NSData dataWithBytes:(UInt8[]){0x55} length:1];
    
    kUriPrefixMap = [[NSArray alloc] initWithObjects:
                                           @"", // 0x00
                                           @"http://www.", // 0x01
                                           @"https://www.", // 0x02
                                           @"http://", // 0x03
                                           @"https://", // 0x04
                                           @"tel:", // 0x05
                                           @"mailto:", // 0x06
                                           @"ftp://anonymous:anonymous@", // 0x07
                                           @"ftp://ftp.", // 0x08
                                           @"ftps://", // 0x09
                                           @"sftp://", // 0x0A
                                           @"smb://", // 0x0B
                                           @"nfs://", // 0x0C
                                           @"ftp://", // 0x0D
                                           @"dav://", // 0x0E
                                           @"news:", // 0x0F
                                           @"telnet://", // 0x10
                                           @"imap:", // 0x11
                                           @"rtsp://", // 0x12
                                           @"urn:", // 0x13
                                           @"pop:", // 0x14
                                           @"sip:", // 0x15
                                           @"sips:", // 0x16
                                           @"tftp:", // 0x17
                                           @"btspp://", // 0x18
                                           @"btl2cap://", // 0x19
                                           @"btgoep://", // 0x1A
                                           @"tcpobex://", // 0x1B
                                           @"irdaobex://", // 0x1C
                                           @"file://", // 0x1D
                                           @"urn:epc:id:", // 0x1E
                                           @"urn:epc:tag:", // 0x1F
                                           @"urn:epc:pat:", // 0x20
                                           @"urn:epc:raw:", // 0x21
                                           @"urn:epc:", // 0x22
                                           nil];
}

- (id)initWithTnf:(short)tnf andType:(NSData *)type andId:(NSData *)theId andPayload:(NSData *)payload {

    return [self initWithTnf:tnf andType:type andId:theId andPayload:payload andFlags:nil];
}

- (id)initWithTnf:(short)tnf andType:(NSData *)type andId:(NSData *)theId andPayload:(NSData *)payload andFlags:(NSData *)flags {
    
    if (self = [super init])
    {
        /* New NDEF records created by applications will have FLAG_MB|FLAG_ME
         * set by default; when multiple records are stored in a
         * {@link NdefMessage}, these flags will be corrected when the {@link NdefMessage}
         * is serialized to bytes.
         */        
        char flag = {kFlagMB|kFlagME};
        
        /* check arguments */
        if ((type == nil) || (payload == nil)) {
            LogError(@"Parsing error: Type or Paylod is null");
            return nil;
        }
        
        if (tnf < 0 || tnf > 0x07) {
            LogError(@"Parsing error: illegal TNF value");
            return nil;
        }
        
        /* Determine if it is a short record */
        if(payload.length < 0xFF) {
            flag |= kFlagSR;
        }
        
        /* Determine if an id is present */
        if(theId.length != 0) {
            flag |= kFlagIL;
        }
        
        _tnf = tnf;
        flags_ = flag;
        _type = [[NSData alloc] initWithData:type];
        _theId = [[NSData alloc] initWithData:theId];
        _payload = [[NSData alloc] initWithData:payload];
    }
    return self;
}

/**
 Returns a byte buffer representation of this NDEF record.
 
 @return NSData
 */
- (NSData *)asByteBuffer; {
    int capacity = 1 + _type.length + _theId.length + _payload.length;
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:capacity];
    char dataBuf;
    
    // TODO: We're assuming an SR here
    
    // Flag Byte
    /* Add TNF back into flag byte */
    char flag = flags_|_tnf;
    
    /* Determine if it is a short record */
    BOOL __unused sr = false;
    if(_payload.length < 0xFF) {
        flag |= kFlagSR;
        sr = true;
    }
    
    /* Determine if an id is present */
    BOOL il = false;
    if(_theId.length != 0) {
        flag |= kFlagIL;
        il = true;
    }
    
    [data appendBytes:&flag length:1];
    
    // Build up data buf
    dataBuf = [_type length];
    [data appendBytes:&dataBuf length:1];
    
    dataBuf = _payload.length;
    [data appendBytes:&dataBuf length:1];
    
    if (il) {
        [data appendData:_theId];
    }
    
    [data appendData:_type];
    
    [data appendData:_payload];
    
    return (NSData *)[data copy];
}

/**
 Where applicable, parses the NDEF Record data payload and returns the embedded URI.
    Must be TNF = WELL_KNOWN with RTD = 0x55 (URI).
 
 @return NSURL  The decoded URL (or nil)
 */
- (NSURL *)getUriFromPayload {
    if (_payload == nil || _tnf == 0 || _type == nil) {
        return nil;
    }
    
    if (_tnf == kTNFWellKnown) {
        int __unused type;
        char typeBuffer[1];
        [_type getBytes:typeBuffer range:NSMakeRange(0, 1)];
        type = typeBuffer[0] & 0xFF;
        
        NSMutableString *urlStringBuilder = [[NSMutableString alloc]initWithCapacity:_payload.length];
        if (_type.length == 1 && [_type isEqualToData:kRTDURI.copy]) {//type == kRTDUri[0]) {            
            NSData *urlPrefixData =[_payload subdataWithRange:NSMakeRange(0,1)];
            UInt8 prefixIndex;
            [urlPrefixData getBytes:&prefixIndex length:1];
            NSString *urlPrefix = [kUriPrefixMap objectAtIndex:prefixIndex];
            [urlStringBuilder appendString:urlPrefix];
            
            NSData *urlPayloadData =[_payload subdataWithRange:NSMakeRange(1, (_payload.length - 1))];
            NSString *urlPayload = [[NSString alloc] initWithData:urlPayloadData encoding:NSASCIIStringEncoding];
            [urlStringBuilder appendString:urlPayload];
            
            NSURL *url = [[NSURL alloc] initWithString:urlStringBuilder];
            return url;
        }
    }

    return nil;
}

+ (NSArray *)parseData:(NSData *)data andIgnoreMbMe:(BOOL)ignoreMbMe {
    
    NSMutableArray *records = [[NSMutableArray alloc] init];
    
    NSData *type = nil;
    NSData *recordId = nil;
    NSData *payload = nil;
//    NSMutableArray *chunks = [[NSMutableArray alloc] init];
    BOOL inChunk = false;
//    short chunkTnf = -1;
    BOOL me = false;
    
    int dataOffset = 0;
    
    while (!me) {
        char flag[1];
        [data getBytes:flag range:NSMakeRange(dataOffset, 1)];
        dataOffset++;
        
        BOOL mb = (flag[0] & kFlagMB) != 0;
        me = (flag[0] & kFlagME) != 0;
        BOOL cf = (flag[0] & kFlagCF) != 0;
        BOOL sr = (flag[0] & kFlagSR) != 0;
        BOOL il = (flag[0] & kFlagIL) != 0;
        short tnf = (short)(flag[0] & 0x07);
        
        if (!mb && [records count] == 0 && !inChunk && !ignoreMbMe) {
            LogError(@"expected MB flag");
            return nil;
        } else if (mb && [records count] != 0 && !ignoreMbMe) {
            LogError(@"expected MB flag");
            return nil;
        } else if (inChunk && il) {
            LogError(@"unexpected IL flag in non-leading chunk");
            return nil;
        } else if (cf && me) {
            LogError(@"unexpected ME flag in non-trailing chunk");
            return nil;
        } else if (inChunk && tnf != kTNFUnchanged) {
            LogError(@"expected TNF_UNCHANGED in non-leading chunk");
            return nil;
        } else if (!inChunk && tnf == kTNFUnchanged) {
            LogError(@"unexpected TNF_UNCHANGED in first chunk or unchunked record");
            return nil;
        }
        
        char typeLengthBuffer[1];
        [data getBytes:typeLengthBuffer range:NSMakeRange(dataOffset, 1)];
        dataOffset++;
        int typeLength = typeLengthBuffer[0] & 0xFF;
        
        long payloadLength;
        if (sr) {
            char payLoadLengthBuffer[1];
            [data getBytes:payLoadLengthBuffer range:NSMakeRange(dataOffset, 1)];
            dataOffset++;
            payloadLength = payLoadLengthBuffer[0] & 0xFF;
        }
        else {
            char payLoadLengthBuffer[3];
            [data getBytes:payLoadLengthBuffer range:NSMakeRange(dataOffset, 3)];
            dataOffset += 3;
                //TODO fix this 
            //payloadLength =  payLoadLengthBuffer & 0xFFFFFFFFL;
        }
        
        int idLength = 0;
        if (il) {
            char idLengthBuffer[1];
            [data getBytes:idLengthBuffer range:NSMakeRange(dataOffset, 1)];
            dataOffset++;
            idLength = idLengthBuffer[0] & 0xFF;
        }
        
        if (inChunk && typeLength != 0) {
            LogError(@"expected zero-length type in non-leading chunk");
            return nil;
        }
        
        if (!inChunk) {
            if (typeLength > 0) {
                type = [data subdataWithRange:NSMakeRange(dataOffset, typeLength)];
                dataOffset += typeLength;
            }
            if (idLength > 0 && idLength <= 3) {
                recordId = [data subdataWithRange:NSMakeRange(dataOffset, idLength)];
                dataOffset += idLength;
            }
        }
        
        if (payloadLength > kMaxPayloadSize) {
            LogError(@"payload length greater than max");
            return nil;
        }
        
        if (payloadLength > 0) {
            if ((dataOffset + payloadLength) <= data.length) {
                payload = [data subdataWithRange:NSMakeRange(dataOffset, payloadLength)];
                dataOffset += payloadLength;
            }
            else {
                return nil;
            }
        }

        if (cf && !inChunk) {
            // first chunk
            // TODO
        }
        if (cf || inChunk) {
            // any chunk
            // TODO
        }
        if (!cf && inChunk) {
            // last chunk, flatten the payload
            // TODO
        }
        if (cf) {
            // more chunks to come
            // TODO
        } else {
            inChunk = false;
        }
        
        NSString *error = [FJNDEFRecord validateTnf:tnf withType:type andRecordId:recordId andPayload:payload];
        if (error != nil) {
            // TODO , throw error
            break;
        }
        
        [records addObject:[[FJNDEFRecord alloc] initWithTnf:tnf andType:type andId:recordId andPayload:payload]];
        
        if (ignoreMbMe) {  // for parsing a single NdefRecord
            break;
        }
    }
    return records;
}

/**
 Ensures TNF is valid for the given type and payload.
 
 @return NSString  Error message
 */
+ (NSString *)validateTnf:(short)tnf withType:(NSData *)type andRecordId:(NSData *)typeId andPayload:(NSData *)payload {
    switch (tnf) {
        case kTNFEmpty:
            if ([type length] != 0 || [typeId length] != 0 || [payload length] != 0) {
                return @"unexpected data in TNF_EMPTY record";
            }
            return nil;
        case kTNFWellKnown:
        case kTNFMimeMedia:
        case kTNFAbsoluteUri:
        case kTNFExternalType:
            return nil;
        case kTNFUnknown:
        case kTNFReserved:
            if ([type length] != 0) {
                return @"unexpected type field in TNF_UNKNOWN or TNF_RESERVEd record";
            }
            return nil;
        case kTNFUnchanged:
            return @"unexpected TNF_UNCHANGED in first chunk or logical record";
        default:
            return @"unexpected tnf value:";
    }
}

#pragma mark - Static helper methods

/**
 NDEF prefix encode the given url and return as an NSData object.
 
 @return NSData
 */
+ (FJNDEFRecord *)createURIWithString:(NSString *)uriString {
    if (uriString == nil) {
        return nil;
    }
    
    uriString = uriString.mutableCopy;
    
    UInt8 prefix = 0;
    for (int i=0; i<kUriPrefixMap.count; i++) {
        if ([uriString hasPrefix:[kUriPrefixMap objectAtIndex:i]]) {
            prefix = (UInt8) i;
            uriString = [uriString substringFromIndex:[(NSString *)[kUriPrefixMap objectAtIndex:i] length]];
            break;
        }
    }
    
    NSMutableData *payload = [[NSMutableData alloc] initWithCapacity:(uriString.length +1)];
    [payload appendBytes:&prefix length:1];
    [payload appendData:[uriString dataUsingEncoding:NSASCIIStringEncoding]];
    
    FJNDEFRecord *ndefRecord = [[FJNDEFRecord alloc] initWithTnf:kTNFWellKnown andType:kRTDURI.copy andId:nil andPayload:payload];
    
    NSLog(@" ndefRecord: %@", ndefRecord.asByteBuffer);
    
    return ndefRecord;
}

/**
 NDEF prefix encode the given url and return as an NSData object.
 
 @return NSData
 */
+ (FJNDEFRecord *)createURIWithURL:(NSURL *)url {
    if (url == nil) {
        return nil;
    }
    return [FJNDEFRecord createURIWithString:url.absoluteString];
}

@end