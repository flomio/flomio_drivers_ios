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


@implementation FJNDEFRecord {
    short       tnf_;
    char        flags_;
    NSData      *type_;
    NSData      *id_;
    NSData      *payload_;
    
    // NFC Forum "URI Record Type Definition"
    //
    // This is a mapping of "URI Identifier Codes" to URI string prefixes,
    // per section 3.2.2 of the NFC Forum URI Record Type Definition document.
    NSArray     *tUriPrefixMap;
}

//typedef enum: short {
//    
////    Indicates no type, id, or payload is associated with this NDEF Record.
////    Type, id and payload fields must all be empty to be a valid TNF_EMPTY
////    record.    
//    kTNFEmpty           = 0x00,
//    
////    Indicates the type field uses the RTD type name format.
////    Use this TNF with RTD types such as RTD_TEXT, RTD_URI.
//    kTNFWellKnown       = 0x01,
//    
////    Indicates the type field contains a value that follows the media-type BNF
////    construct defined by RFC 2046.
//    kTNFMimeMedia       = 0x02,
//    
////    Indicates the type field contains a value that follows the absolute-URI
////    BNF construct defined by RFC 3986.
//    kTNFAbsoluteUri     = 0x03,
//    
////    Indicates the type field contains a value that follows the RTD external
////    name specification.
////    Note this TNF should not be used with RTD_TEXT or RTD_URI constants.
////    Those are well known RTD constants, not external RTD constants.
//    kTNFExternalType    = 0x04,
//    
////    Indicates the payload type is unknown.
////    This is similar to the "application/octet-stream" MIME type. The payload
////    type is not explicitly encoded within the NDEF Message.
////    The type field must be empty to be a valid TNF_UNKNOWN record.
//    kTNFUnknown         = 0x05,
//    
////    Indicates the payload is an intermediate or final chunk of a chunked
////    NDEF Record.
////    The payload type is specified in the first chunk, and subsequent chunks
////    must use TNF_UNCHANGED with an empty type field. TNF_UNCHANGED must not
////    be used in any other situation.
//    kTNFUnchanged       = 0x06,
//    
////    Reserved TNF type.
////    The NFC Forum NDEF Specification v1.0 suggests for NDEF parsers to treat this
////    value like TNF_UNKNOWN.
//    kTnfReserved        = 0x07,
//} tnfValues;



//    Indicates no type, id, or payload is associated with this NDEF Record.
//    Type, id and payload fields must all be empty to be a valid TNF_EMPTY
//    record.
static const UInt8 kTNFEmpty           = 0x00;

//    Indicates the type field uses the RTD type name format.
//    Use this TNF with RTD types such as RTD_TEXT, RTD_URI.
static const UInt8 kTNFWellKnown       = 0x01;

//    Indicates the type field contains a value that follows the media-type BNF
//    construct defined by RFC 2046.
static const UInt8 kTNFMimeMedia       = 0x02;

//    Indicates the type field contains a value that follows the absolute-URI
//    BNF construct defined by RFC 3986.
static const UInt8 kTNFAbsoluteUri     = 0x03;

//    Indicates the type field contains a value that follows the RTD external
//    name specification.
//    Note this TNF should not be used with RTD_TEXT or RTD_URI constants.
//    Those are well known RTD constants, not external RTD constants.
static const UInt8 kTNFExternalType    = 0x04;

//    Indicates the payload type is unknown.
//    This is similar to the "application/octet-stream" MIME type. The payload
//    type is not explicitly encoded within the NDEF Message.
//    The type field must be empty to be a valid TNF_UNKNOWN record.
static const UInt8 kTNFUnknown         = 0x05;

//    Indicates the payload is an intermediate or final chunk of a chunked
//    NDEF Record.
//    The payload type is specified in the first chunk, and subsequent chunks
//    must use TNF_UNCHANGED with an empty type field. TNF_UNCHANGED must not
//    be used in any other situation.
static const UInt8 kTNFUnchanged       = 0x06;

//    Reserved TNF type.
//    The NFC Forum NDEF Specification v1.0 suggests for NDEF parsers to treat this
//    value like TNF_UNKNOWN.
static const UInt8 kTNFReserved        = 0x07;

// RTD Text type. For use with TNF_WELL_KNOWN.
static const UInt8 kRTDText[] = {0x54}; // "T"

// RTD URI type. For use with TNF_WELL_KNOWN.
static const UInt8 kRTDUri[] = {0x55};   // "U"

// RTD Smart Poster type. For use with TNF_WELL_KNOWN.
static const UInt8 kRTDSmartPost[] = {0x53, 0x70};  // "Sp"

// RTD Alternative Carrier type. For use with TNF_WELL_KNOWN.
static const UInt8 kRTDAlternativeCarrier[] = {0x61, 0x63}; // "ac"

// RTD Handover Carrier type. For use with TNF_WELL_KNOWN.
static const UInt8 kRTDHandoverCarrier[] = {0x48, 0x63};  // "Hc"

// RTD Handover Request type. For use with TNF_WELL_KNOWN.
static const UInt8 kRTDHandoverRequest[] = {0x48, 0x72};  // "Hr"

// RTD Handover Select type. For use with TNF_WELL_KNOWN.
static const UInt8 kRTDHandoverSelect[] = {0x48, 0x73}; // "Hs"

// NDEF flag mask: Message Begins
static const UInt8 kFlagMB = 0x80;

// NDEF flag mask: Message Ends
static const UInt8 kFlagME = 0x40;

// NDEF flag mask: Chunk Flag
static const UInt8 kFlagCF = 0x20;

// NDEF flag mask: Short Record
static const UInt8 kFlagSR = 0x10;

// NDEF flag mask: ID Length Present
static const UInt8 kFlagIL = 0x08;

// 10 MB NDEF record payload limit
static const long kMaxPayloadSize = 10 * (1 << 20);

static const UInt8 kEmptyByteArray[] = {0x00};


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
            [NSException raise:@"Illegal Argument" format:@"Agrument is null"];
        }
        
        if (tnf < 0 || tnf > 0x07) {
            [NSException raise:@"TNF Error" format:@"TNF is out of range"];
        }
        
        /* Determine if it is a short record */
        if(payload.length < 0xFF) {
            flag |= kFlagSR;
        }
        
        /* Determine if an id is present */
        if(theId.length != 0) {
            flag |= kFlagIL;
        }
        
        tnf_ = tnf;
        flags_ = flag;
        type_ = [[NSData alloc] initWithData:type];
        id_ = [[NSData alloc] initWithData:theId];
        payload_ = [[NSData alloc] initWithData:payload];
        
        tUriPrefixMap = [NSArray arrayWithObjects:@"", // 0x00
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
    return self;
}

- (NSData *)asByteBuffer; {
    int capacity = 1 + type_.length + id_.length + payload_.length;
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:capacity];
    
    /* Add TNF back into flag byte */
    char flag = flags_|tnf_;
    
    /* Determine if it is a short record */
    BOOL sr = false;
    if(payload_.length < 0xFF) {
        flag |= kFlagSR;
        sr = true;
    }
    
    /* Determine if an id is present */
    BOOL il = false;
    if(id_.length != 0) {
        flag |= kFlagIL;
        il = true;
    }
    
    [data appendBytes:&flag length:1];
    
    char typeLength = (char) [type_ length];
    [data appendBytes:&typeLength length:1];
    
    
    
    
    
    
    return (NSData *)[data copy];
}


- (FJNDEFRecord *)createUriRecordFromUri:(NSURL *)url {
    return [self createUriRecordFromUriString:[url absoluteString]];
}

- (FJNDEFRecord *)createUriRecordFromUriString:(NSString *)uriString {
    // TODO: stub method to quiet compiler
    
//    UInt8 prefix = 0x0;
    for (int i = 1; i < [tUriPrefixMap count]; i++) {
//        if (uriString.startsWith(URI_PREFIX_MAP[i])) {
//            prefix = (byte) i;
//            uriString = uriString.substring(URI_PREFIX_MAP[i].length());
//            break;
//        }
    }
//    byte[] uriBytes = uriString.getBytes(Charsets.UTF_8);
//    byte[] recordBytes = new byte[uriBytes.length + 1];
//    recordBytes[0] = prefix;
//    System.arraycopy(uriBytes, 0, recordBytes, 1, uriBytes.length);
//    return new NdefRecord(TNF_WELL_KNOWN, RTD_URI, new byte[0], recordBytes);
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
            //throw new FormatException("expected MB flag");
        } else if (mb && [records count] != 0 && !ignoreMbMe) {
            //throw new FormatException("unexpected MB flag");
        } else if (inChunk && il) {
            //throw new FormatException("unexpected IL flag in non-leading chunk");
        } else if (cf && me) {
            //throw new FormatException("unexpected ME flag in non-trailing chunk");
        } else if (inChunk && tnf != kTNFUnchanged) {
            //throw new FormatException("expected TNF_UNCHANGED in non-leading chunk");
        } else if (!inChunk && tnf == kTNFUnchanged) {
            //throw new FormatException("" +
            //                          "unexpected TNF_UNCHANGED in first chunk or unchunked record");
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
            [data getBytes:typeLengthBuffer range:NSMakeRange(dataOffset, 1)];
            dataOffset++;
            idLength = idLengthBuffer[0] & 0xFF;
        }
        
        
        if (inChunk && typeLength != 0) {
            //throw new FormatException("expected zero-length type in non-leading chunk");
        }
        
        if (!inChunk) {
            if (typeLength > 0) {
                type = [data subdataWithRange:NSMakeRange(dataOffset, typeLength)];
                dataOffset += typeLength;
            }
            if (idLength > 0) {
                recordId = [data subdataWithRange:NSMakeRange(dataOffset, idLength)];
                dataOffset += idLength;
            }
        }
        
        if (payloadLength > kMaxPayloadSize) {
            // TODO
            return nil;
        }
        
        if (payloadLength > 0) {
                payload = [data subdataWithRange:NSMakeRange(dataOffset, payloadLength)];
                dataOffset += payloadLength;
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
            //return String.format("unexpected tnf value: 0x%02x", tnf);
    }
}

@end
